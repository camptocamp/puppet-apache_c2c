class apache::base::ssl {

  if $apache_ssl_ports {} else { $apache_ssl_ports = [443] }

  if $sslcert_country {} else { $sslcert_country = "??" }
  if $sslcert_state {} else { $sslcert_state = "undefined state" }
  if $sslcert_locality {} else { $sslcert_locality = "undefined locality" }
  if $sslcert_organisation {} else { $sslcert_organisation = "undefined organisation" }
  if $sslcert_unit {} else { $sslcert_unit = "undefined unit" }
  if $sslcert_email {} else { $sslcert_email = "undefined email" }

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
