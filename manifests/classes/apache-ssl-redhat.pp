class apache::ssl::redhat inherits apache::base::ssl {

  package {"mod_ssl":
    ensure => installed,
  }

  file {"/etc/httpd/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

  apache::module { "ssl":
    ensure => present,
    require => File["/etc/httpd/conf.d/ssl.conf"],
    notify => Service["apache"],
    before => Exec["apache-graceful"],
  }

}
