class apache_c2c::webdav::base {

  case $::operatingsystem {

    Debian,Ubuntu:  {

      package {'libapache2-mod-encoding':
        ensure => present,
      }

      apache_c2c::module {'encoding':
        ensure  => present,
        require => Package['libapache2-mod-encoding'],
      }

      # Other OS: If you encounter issue with encoding, read the description of
      # the Debian package:
      # http://packages.debian.org/squeeze/libapache2-mod-encoding


    }

    default: {}

  }

  apache_c2c::module {['dav', 'dav_fs']:
    ensure => present,
  }

  if !defined(Apache_c2c::Module['headers']) {
    apache_c2c::module {'headers':
      ensure => present,
    }
  }

}
