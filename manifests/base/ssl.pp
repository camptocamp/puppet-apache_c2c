/*

== Class: apache::base::ssl

Common building blocks between apache::ssl::debian and apache::ssl::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base::ssl {

  apache::listen { "443": ensure => present }
  apache::namevhost { "*:443": ensure => present }

  file { "/usr/local/sbin/generate-ssl-cert.sh":
    source => "puppet:///modules/apache/generate-ssl-cert.sh",
    mode   => 755,
  }

}
