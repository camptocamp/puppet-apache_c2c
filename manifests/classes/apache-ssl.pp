class apache::ssl inherits apache::base {

  case $operatingsystem {

    RedHat: {
      package { "mod_ssl":
        ensure => installed,
      }

      file { "$wwwconf/conf.d/ssl.conf":
        ensure => absent,
        require => Package["mod_ssl"],
        notify => Service["$wwwpkgname"],
      }

      apache::module { "mod_ssl":
        ensure => present,
        alias => "ssl",
        require => File["$wwwconf/conf.d/ssl.conf"],
        notify => Service["$wwwpkgname"],
      }
    }

    Debian: {
      apache::module {"ssl":
        ensure => present,
      }

      file { "$wwwconf/ports.conf":
        content => "Listen 80\nListen 443\n",
        notify  => Service["$wwwpkgname"],
        require => Package["$wwwpkgname"],
      }
    }
  }

  file { "/etc/ssl/":
    ensure => directory,
  }

  file { "/etc/ssl/ssleay.cnf":
    source => "puppet:///apache/ssleay.cnf",
    require => File["/etc/ssl/"],
  }

  file { "/usr/local/sbin/generate-ssl-cert.sh":
    source => "puppet:///apache/generate-ssl-cert.sh",
    mode   => 755,
  }

}
