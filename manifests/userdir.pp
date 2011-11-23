class apache::userdir {

  file {"/etc/skel/public_html":
    ensure => directory,
  }

  file {"/etc/skel/public_html/htdocs":
    ensure => directory,
    require => File["/etc/skel/public_html"]
  }

  file {"/etc/skel/public_html/conf":
    require => File["/etc/skel/public_html"],
    ensure => directory
  }

  file {"/etc/skel/public_html/cgi-bin":
    require => File["/etc/skel/public_html"],
    ensure => directory
  }

  file {"/etc/skel/public_html/private":
    require => File["/etc/skel/public_html"],
    ensure => directory
  }

  file {"/etc/skel/public_html/README":
    require => File["/etc/skel/public_html"],
    ensure => present,
    source => 'puppet:///modules/apache/README_userdir',
  }

  apache::module { "userdir":
    ensure => present,
  }

  # Disable global userdir activation
  file {"/etc/apache2/mods-enabled/userdir.conf":
    ensure => absent,
    notify => Exec["apache-graceful"],
  }

}
