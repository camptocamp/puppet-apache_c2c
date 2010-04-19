/*
== Definition: apache::listen

Adds a "Listen" directive to apache's port.conf file.

Parameters:
- *ensure*: present/absent.
- *name*: port number, or ipaddress:port

Requires:
- Class["apache"]

Example usage:

  apache::listen { "80": }
  apache::listen { "127.0.0.1:8080": ensure => present }

*/
define apache::listen ($ensure='present') {

  common::concatfilepart { "apache-ports.conf-${name}":
    ensure  => $ensure,
    manage  => true,
    content => "Listen ${name}\n",
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
