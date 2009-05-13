class apache::security {

  case $operatingsystem {

    RedHat: {
      package { "mod_security":
        ensure => present,
        alias => "apache-mod_security",
      }

      file { "/etc/httpd/conf.d/mod_security.conf":
        ensure => absent,
        require => Package["mod_security"],
        notify => Service["apache"],
      }
    }

    Debian: {
      package { "libapache-mod-security":
        ensure => present,
        alias => "apache-mod_security",
      }
    }
  }

  apache::module { ["unique_id", "security"]:
    ensure => present,
    require => Package["apache-mod_security"],
  }

}
