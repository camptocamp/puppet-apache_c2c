/*

== Class: apache::base

Common building blocks between apache::debian and apache::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base {

  if $apache_ports {} else { $apache_ports = [80] }

  file {"root directory":
    path => undef,
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"cgi-bin directory":
    path => undef,
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"log directory":
    path => undef,
    ensure => directory,
    mode => 755,
    owner => "root",
    group  => "root",
    require => Package["apache"],
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
