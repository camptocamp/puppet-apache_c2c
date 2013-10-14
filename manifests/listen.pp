# == Definition: apache::listen
#
# Adds a "Listen" directive to apache's port.conf file.
#
# Parameters:
# - *ensure*: present/absent.
# - *name*: port number, or ipaddress:port
#
# Requires:
# - Class["apache"]
#
# Example usage:
#
#   apache_c2c::listen { "80": }
#   apache_c2c::listen { "127.0.0.1:8080": ensure => present }
#
define apache_c2c::listen ($ensure='present') {

  include apache_c2c::params

  concat::fragment { "apache-ports.conf-${name}":
    ensure  => $ensure,
    target  => "${apache_c2c::params::conf}/ports.conf",
    content => "Listen ${name}\n",
  }

}
