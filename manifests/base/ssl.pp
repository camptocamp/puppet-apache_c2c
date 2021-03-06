# == Class: apache::base::ssl
#
# Common building blocks between apache::ssl::debian and apache::ssl::redhat.
#
# It shouldn't be necessary to directly include this class.
#
class apache_c2c::base::ssl {
  apache_c2c::listen { '443': ensure => present }
  apache_c2c::namevhost { '*:443': ensure => present }
}
