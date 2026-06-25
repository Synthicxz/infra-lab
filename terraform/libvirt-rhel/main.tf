resource "libvirt_volume" "vm_disk" {
  name = "${var.vm_name}.qcow2"
  pool = "default"

  # 10 GiB, matching the current RHEL base image virtual size.
  capacity = 10737418240

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = var.base_image_path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "vm_init" {
  name      = "${var.vm_name}-cloudinit"
  user_data = file("${path.module}/cloud-init.cfg")

  meta_data = <<-EOF
instance-id: ${var.vm_name}
local-hostname: ${var.vm_name}
EOF
  /*
  network_config = <<-EOF
version: 2
ethernets:
  default:
  match:
    name: "en*"
    dhcp4: true
EOF
*/
}

resource "libvirt_volume" "cloudinit_iso" {
  name = "${var.vm_name}-cloudinit.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.vm_init.path
    }
  }
}

resource "libvirt_domain" "vm" {
  name        = var.vm_name
  type        = "kvm"
  memory      = var.vm_memory_mib
  memory_unit = "MiB"
  vcpu        = var.vm_vcpus

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }

  features = {
    acpi = true
    apic = {}
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = libvirt_volume.vm_disk.pool
            volume = libvirt_volume.vm_disk.name
          }
        }

        target = {
          bus = "virtio"
          dev = "vda"
        }

        driver = {
          type = "qcow2"
        }
      },
      {
        device = "cdrom"

        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_iso.pool
            volume = libvirt_volume.cloudinit_iso.name
          }
        }

        target = {
          bus = "sata"
          dev = "sda"
        }
      }
    ]

    interfaces = [
      {
        type = "network"

        model = {
          type = "virtio"
        }

        source = {
          network = {
            network = "default"
          }
        }

        wait_for_ip = {
          timeout = 300
          source  = "lease"
        }
      }
    ]

    graphics = [
      {
        vnc = {
          auto_port = true
          listen    = "127.0.0.1"
        }
      }
    ]

    channels = [
      {
        source = {
          unix = {
            mode = "bind"
          }
        }

        target = {
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      }
    ]
  }

  running = true
}

data "libvirt_domain_interface_addresses" "vm" {
  domain = libvirt_domain.vm.name
  source = "lease"

  depends_on = [libvirt_domain.vm]
}

output "vm_name" {
  value = libvirt_domain.vm.name
}

output "vm_ip" {
  value = data.libvirt_domain_interface_addresses.vm.interfaces[0].addrs[0].addr
}

output "ssh_command" {
  value = "ssh -J jordan@archbox admin@${data.libvirt_domain_interface_addresses.vm.interfaces[0].addrs[0].addr}"
}

