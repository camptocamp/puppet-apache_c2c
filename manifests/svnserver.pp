class apache_c2c::svnserver inherits apache_c2c::ssl {

  case $::operatingsystem {

    Debian,Ubuntu:  {
      $pkglist = [ 'libapache2-svn' ]
    }

    RedHat,CentOS:  {
      $pkglist = [ 'mod_dav_svn' ]
    }

    default: {
      fail "Unsupported operatingsystem ${::operatingsystem}"
    }

  }

  package {
    $pkglist:
    ensure => present,
  }

  apache_c2c::module {
    [
      'dav',
      'dav_svn',
    ]:
    ensure  => present,
    require => Package[ $pkglist ],
  }

}
