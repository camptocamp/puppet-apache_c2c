class apache::userdir {

  file {'/etc/skel/public_html':
    ensure => directory,
  }

  file {'/etc/skel/public_html/htdocs':
    ensure  => directory,
    require => File['/etc/skel/public_html'],
  }

  file {'/etc/skel/public_html/conf':
    ensure  => directory,
    require => File['/etc/skel/public_html'],
  }

  file {'/etc/skel/public_html/cgi-bin':
    ensure  => directory,
    require => File['/etc/skel/public_html'],
  }

  file {'/etc/skel/public_html/private':
    ensure  => directory,
    require => File['/etc/skel/public_html'],
  }

  file {'/etc/skel/public_html/README':
    ensure  => present,
    require => File['/etc/skel/public_html'],
    source  => "puppet:///modules/${module_name}/README_userdir",
  }

  apache::module { 'userdir':
    ensure => present,
  }

  # Disable global userdir activation
  file {'/etc/apache2/mods-enabled/userdir.conf':
    ensure => absent,
    notify => Exec['apache-graceful'],
  }

}
