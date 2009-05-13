class apache::ssl::redhat inherits apache::base::ssl {

  package {"mod_ssl":
    ensure => installed,
  }

  file {"/etc/httpd/conf.d/ssl.conf":
    ensure => absent,
    require => Package["mod_ssl"],
    notify => Service["apache"],
  }

  apache::module { "ssl":
    ensure => present,
    require => File["/etc/httpd/conf.d/ssl.conf"],
    notify => Service["apache"],
  }

  #TODO: transitional resources, remove soon
  apache::module { "mod_ssl":
    ensure => absent,
    require => Apache::Module["ssl"],
  }
  file { "/etc/httpd/mods-available/mod_ssl.load":
    ensure => absent,
    require => Apache::Module["mod_ssl"],
  }

}
