class apache::ssl::redhat inherits apache::redhat {

  package {"mod_ssl":
    ensure => installed,
  }

  file {"/etc/httpd/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache2"],
  }

  apache::module { "mod_ssl":
    ensure => present,
    alias => "ssl",
    require => File["/etc/httpd/conf.d/ssl.conf"],
    notify => Service["apache2"],
  }

}
