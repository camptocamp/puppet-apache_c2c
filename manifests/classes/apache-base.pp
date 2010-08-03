/*

== Class: apache::base

Common building blocks between apache::debian and apache::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base {

  include apache::params

  file {"root directory":
    path => $apache::params::root,
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"cgi-bin directory":
    path => $apache::params::cgi,
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"log directory":
    path => $apache::params::log,
    ensure => directory,
    mode => 755,
    owner => "root",
    group  => "root",
    require => Package["apache"],
  }

  user { "apache user":
    name    => $apache::params::user,
    ensure  => present,
    require => Package["apache"],
    shell   => "/bin/sh",
  }

  group { "apache group":
    name    => $apache::params::user,
    ensure  => present,
    require => Package["apache"],
  }

  package { "apache":
    name   => $apache::params::pkg,
    ensure => installed,
  }

  service { "apache":
    name       => $apache::params::pkg,
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package["apache"],
  }

  file {"logrotate configuration":
    path => undef,
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    source => undef,
    require => Package["apache"],
  }

  apache::listen { "80": ensure => present }
  apache::namevhost { "*:80": ensure => present }

  apache::module {["alias", "auth_basic", "authn_file", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "dir", "env", "mime", "negotiation", "rewrite", "setenvif", "status", "cgi"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

  file {"default status module configuration":
    path => undef,
    ensure => present,
    owner => root,
    group => root,
    source => undef,
    require => Module["status"],
    notify => Exec["apache-graceful"],
  }

  file {"default virtualhost":
    path => undef,
    ensure => present,
    content => undef,
    require => Package["apache"],
    notify => Exec["apache-graceful"],
    mode => 644,
  }

  exec { "apache-graceful":
    command => undef,
    refreshonly => true,
    onlyif => undef,
  }

  file {"/usr/local/bin/htgroup":
    ensure => present,
    owner => root,
    group => root,
    mode => 755,
    source => "puppet:///apache/usr/local/bin/htgroup",
  }

}
