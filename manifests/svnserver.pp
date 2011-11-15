class apache::svnserver inherits apache::ssl {
  package {"libapache2-svn":
    ensure => present,
  }

  apache::module {"dav":
    ensure => present,
  }

  apache::module {"dav_svn":
    ensure  => present,
    require => Package["libapache2-svn"],
  }

}
