class apache::webdav::base {

  package {"libapache2-mod-encoding":
    ensure => present,
  }

  apache::module {["dav", "dav_fs"]:
    ensure => present,
  }

  if !defined(Apache::Module["headers"]) {
    apache::module {"headers":
      ensure => present,
    }
  }

  apache::module {"encoding":
    ensure  => present,
    require => Package["libapache2-mod-encoding"],
  }

}
