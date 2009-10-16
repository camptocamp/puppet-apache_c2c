class apache::ssl::debian inherits apache::base::ssl {

  apache::module {"ssl":
    ensure => present,
  }

  case $lsbdistcodename {
    etch: {
      line {"listen on port 443":
        ensure => present,
        line => "Listen 443",
        file => "/etc/apache2/ports.conf",
        notify  => Service["apache"],
        require => Package["apache"],
      }
    }
  }

  if !defined(Package["ca-certificates"]) {
    package { "ca-certificates":
      ensure => present,
    }
  }
}
