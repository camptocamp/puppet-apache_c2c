# == Class: apache::base
#
# Common building blocks between apache::debian and apache::redhat.
#
# It shouldn't be necessary to directly include this class.
#
class apache_c2c::base {

  include apache_c2c::params
  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $access_log = $apache_c2c::params::access_log
  $error_log  = $apache_c2c::params::error_log

  concat {"${apache_c2c::params::conf}/ports.conf":
    notify  => Service['apache'],
    require => Package['apache'],
  }

  # removed this folder originally created by common::concatfilepart
  file {"${apache_c2c::params::conf}/ports.conf.d":
    ensure  => absent,
    purge   => true,
    recurse => true,
    force   => true,
  }

  file {'root directory':
    ensure  => directory,
    path    => $wwwroot,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['apache'],
  }

  file {'log directory':
    ensure  => directory,
    path    => $apache_c2c::params::log,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package['apache'],
  }

  user { 'apache user':
    ensure  => present,
    name    => $apache_c2c::params::user,
    require => Package['apache'],
    shell   => '/bin/sh',
  }

  group { 'apache group':
    ensure  => present,
    name    => $apache_c2c::params::user,
    require => Package['apache'],
  }

  package { 'apache':
    ensure => installed,
    name   => $apache_c2c::params::pkg,
  }

  $service_ensure = $apache_c2c::service_ensure ? {
    'unmanaged' => undef,
    default     => $apache_c2c::service_ensure,
  }
  service { 'apache':
    ensure     => $service_ensure,
    name       => $apache_c2c::params::pkg,
    enable     => $apache_c2c::service_enable,
    hasrestart => true,
    require    => Package['apache'],
  }

  file {'logrotate configuration':
    ensure  => present,
    path    => undef,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => undef,
    require => Package['apache'],
  }

  if ! $apache_c2c::disable_port80 {

    apache_c2c::listen { '80': ensure => present }
    apache_c2c::namevhost { '*:80': ensure => present }

  }

  apache_c2c::module {['alias', 'auth_basic', 'authn_file', 'authz_default',
  'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env',
  'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'cgi']:
    ensure => present,
    notify => Exec['apache-graceful'],
  }

  file {'default status module configuration':
    ensure  => present,
    path    => undef,
    owner   => root,
    group   => root,
    source  => undef,
    require => Module['status'],
    notify  => Exec['apache-graceful'],
  }

  file {'default virtualhost':
    ensure  => present,
    path    => "${apache_c2c::params::conf}/sites-available/default-vhost",
    content => template("${module_name}/default-vhost.erb"),
    require => Package['apache'],
    notify  => Exec['apache-graceful'],
    before  => File["${apache_c2c::params::conf}/sites-enabled/000-default-vhost"],
    mode    => '0644',
  }

  if ! ($::apache_c2c::default_vhost or $::apache_c2c::ssl::default_vhost) {

    file { "${apache_c2c::params::conf}/sites-enabled/000-default-vhost":
      ensure => absent,
      notify => Exec['apache-graceful'],
    }

  } else {

    file { "${apache_c2c::params::conf}/sites-enabled/000-default-vhost":
      ensure => link,
      target => "${apache_c2c::params::conf}/sites-available/default-vhost",
      notify => Exec['apache-graceful'],
    }

    file { "${wwwroot}/html":
      ensure  => directory,
    }

  }

  exec { 'apache-graceful':
    command     => undef,
    refreshonly => true,
    onlyif      => undef,
  }

  file {'/usr/local/bin/htgroup':
    ensure => present,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/usr/local/bin/htgroup",
  }

  file { ["${apache_c2c::params::conf}/sites-enabled/default",
          "${apache_c2c::params::conf}/sites-enabled/000-default",
          "${apache_c2c::params::conf}/sites-enabled/default-ssl"]:
    ensure => absent,
    notify => Exec['apache-graceful'],
  }

}
