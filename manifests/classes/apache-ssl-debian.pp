class apache::ssl::debian inherits apache::base::ssl {

  apache::module {"ssl":
    ensure => present,
  }

  common::concatfilepart {"apache.ports.ssl":
    ensure  => present,
    file    => "/etc/apache2/ports.conf",
    content => template("apache/ports.ssl.conf.erb"),
    require => Package["apache"],
    notify  => Service["apache"],
  }

  if !defined(Package["ca-certificates"]) {
    package { "ca-certificates":
      ensure => present,
    }
  }
}
