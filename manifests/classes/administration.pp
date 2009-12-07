class apache::administration {

  case $operatingsystem {
    redhat,CentOS: {
      $wwwuser = "apache"
      $wwwpkgname = "httpd"
      $distro_specific_apache_sudo = "/usr/sbin/apachectl, /sbin/service ${wwwpkgname}"
    }
    debian: {
      $wwwuser =  "www-data"
      $wwwpkgname = "apache2"
      $distro_specific_apache_sudo = "/usr/sbin/apache2ctl"
    }
  }

  group { "apache-admin":
    ensure => present,
  }

  common::concatfilepart { "sudoers.apache":
    ensure => present,
    file => "/etc/sudoers",
    content => template("apache/sudoers.apache.erb"),
    require => Group["apache-admin"],
  }

}
