/*

== Class: apache::base::ssl

Common building blocks between apache::ssl::debian and apache::ssl::redhat.

It shouldn't be necessary to directly include this class.

*/
class apache::base::ssl {

  if $apache_ssl_ports {} else { $apache_ssl_ports = [443] }

  if !$sslcert_country { $sslcert_country = "??" }
  if !$sslcert_organisation { $sslcert_organisation = "undefined organisation" }

  file { "/etc/ssl/":
    ensure => directory,
  }

  file { "/etc/ssl/ssleay.cnf":
    content => template("apache/ssleay.cnf.erb"),
    require => File["/etc/ssl/"],
  }

  file { "/usr/local/sbin/generate-ssl-cert.sh":
    source => "puppet:///apache/generate-ssl-cert.sh",
    mode   => 755,
  }

}
