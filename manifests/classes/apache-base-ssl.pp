class apache::base::ssl {

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
