class apache::ssl::redhat inherits apache::ssl {

  package {"mod_ssl":
    ensure => installed,
  }

  file {"/etc/httpd/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache"],
  }

  apache::module { "mod_ssl":
    ensure => present,
    alias => "ssl",
    require => File["/etc/httpd/conf.d/ssl.conf"],
    notify => Service["apache"],
  }

}
