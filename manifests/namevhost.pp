# == Definition: apache::namevhost
#
# Adds a "NameVirtualHost" directive to apache's port.conf file.
#
# Every "ports" parameter you define Apache_c2c::Vhost resources should have a
# matching NameVirtualHost directive.
#
# Parameters:
# - *ensure*: present/absent.
# - *name*: ipaddress or ipaddress:port
#
# Requires:
# - Class["apache"]
#
# Example usage:
#
#   apache_c2c::namevhost { "*:80": }
#   apache_c2c::namevhost { "127.0.0.1:8080": ensure => present }
#
define apache_c2c::namevhost ($ensure='present') {

  include apache_c2c::params

  concat::fragment { "apache-namevhost.conf-${name}":
    ensure  => $ensure,
    target  => "${apache_c2c::params::conf}/ports.conf",
    content => "NameVirtualHost ${name}\n",
  }

}
