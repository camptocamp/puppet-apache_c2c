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

  common::concatfilepart { "apache-namevhost.conf-${name}":
    ensure  => $ensure,
    manage  => true,
    content => "NameVirtualHost ${name}\n",
    file    => $operatingsystem ? {
      Debian => "/etc/apache2/ports.conf",
      Ubuntu => "/etc/apache2/ports.conf",
      RedHat => "/etc/httpd/ports.conf",
      CentOS => "/etc/httpd/ports.conf",
    },
    require => Package["apache"],
    notify  => Service["apache"],
  }

}
