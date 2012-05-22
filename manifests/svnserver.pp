class apache::svnserver inherits apache::ssl {

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

  apache::module {
    [
      "dav",
      "dav_svn",
    ]:
    ensure  => present,
    require => Package[ $pkglist ],
  }

}
