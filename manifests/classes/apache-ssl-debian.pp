class apache::ssl::debian inherits apache::ssl {

  apache::module {"ssl":
    ensure => present,
  }

  common::line {"set https port":
    ensure => present,
    line => "Listen 443",
    file => "/etc/apache2/ports.conf",
    notify  => Service["apache"],
    require => Package["apache"],
  }

}
