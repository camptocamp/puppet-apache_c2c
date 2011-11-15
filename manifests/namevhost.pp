/*
== Definition: apache::namevhost

Adds a "NameVirtualHost" directive to apache's port.conf file.

Every "ports" parameter you define Apache::Vhost resources should have a
matching NameVirtualHost directive.

Parameters:
- *ensure*: present/absent.
- *name*: ipaddress or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  apache::namevhost { "*:80": }
  apache::namevhost { "127.0.0.1:8080": ensure => present }

*/
define apache::namevhost ($ensure='present') {

  include apache::params

  common::concatfilepart { "apache-namevhost.conf-${name}":
    ensure  => $ensure,
    manage  => true,
    content => "NameVirtualHost ${name}\n",
    file    => "${apache::params::conf}/ports.conf",
    require => Package["apache"],
    notify  => Service["apache"],
  }

}
