class apache::davfsserver inherits apache::ssl {

  package {"libapache2-mod-encoding":
    ensure => present,
  }

  apache::module {["dav", "dav_fs", "headers"]:
    ensure => present,
  }

  apache::module {"encoding":
    ensure  => present,
    require => Package["libapache2-mod-encoding"],
  }

# cf: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=420101
  file {"/var/lock/apache2":
    ensure  => directory,
    owner   => www-data,
    group   => root,
    mode    => 755,
  }

}
