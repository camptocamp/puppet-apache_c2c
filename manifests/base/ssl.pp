/*

== Class: apache::base::ssl

Common building blocks between apache::ssl::debian and apache::ssl::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base::ssl {

  apache::listen { "${apache::params::ssl_port}": ensure => present }
  apache::namevhost { "${apache::params::ssl_port}": ensure => present }

  file { "/usr/local/sbin/generate-ssl-cert.sh":
    source => "puppet:///modules/${module_name}/generate-ssl-cert.sh",
    mode   => '0755',
  }

}
