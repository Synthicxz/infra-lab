class lab_status (
  String               $service_user, 
  String               $service_group,
  String               $home_dir,
  String               $content_dir,
  Integer[1024, 65535] $port,
) {

  group { $service_group:
    ensure => present,
    system => true,
  }

  user { $service_user:
    ensure     => present,
    system     => true,
    gid        => $service_group,
    home       => $home_dir,
    shell      => '/sbin/nologin',
    managehome => true,
  }

  package { 'python3':
    ensure => installed,
  }

  file { $content_dir:
    ensure => directory,
    owner  => $service_user,
    group  => $service_group,
    mode   => '0755',
  }

  file { "${content_dir}/index.html":
    ensure => file,
    owner  => $service_user,
    group  => $service_group,
    mode   => '0644',
    source => 'puppet:///modules/lab_status/index.html',
  }

  file { '/etc/systemd/system/lab-status.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp(
      'lab_status/lab-status.service.epp',
      {
        'service_user'  => $service_user,
        'service_group' => $service_group,
        'content_dir'   => $content_dir,
        'port'          => $port,
      },
    ),
  }

  exec { 'systemd-daemon-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'lab-status':
    ensure => running,
    enable => true,
  }

  Group[$service_group]
    -> User[$service_user]
    -> File[$content_dir]
    -> File["${content_dir}/index.html"]

  Package['python3']
    -> Service['lab-status']

  File['/etc/systemd/system/lab-status.service']
    ~> Exec['systemd-daemon-reload']
    ~> Service['lab-status']
}
