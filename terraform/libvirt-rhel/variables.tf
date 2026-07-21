variable "vm_name" {
  description = "Name of the Terraform-created RHEL VM"
  type        = string
  default     = "tf-rhel-01"
}

variable "vm_memory_mib" {
  description = "vm memory in MiB"
  type        = number
  default     = 2048
}

variable "vm_vcpus" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
}

variable "base_image_path" {
  description = "Path to the staged RHEL qcow2 base image on the libvirt host"
  type        = string
  default     = "/var/lib/libvirt/images/templates/rhel9-base.qcow2"
}
