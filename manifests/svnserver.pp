class apache_c2c::svnserver inherits apache_c2c::ssl {

  case $::osfamily {

    'Debian':  {
      $pkglist = [ 'libapache2-svn' ]
    }

    'RedHat':  {
      $pkglist = [ 'mod_dav_svn' ]
    }

    default: {
      fail "Unsupported osfamily ${::osfamily}"
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
