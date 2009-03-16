class apache::administration {

  case $operatingsystem {
    redhat: {
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
    content => "
# This part comes from modules/apache/manifests/classes/administration.pp
%apache-admin ALL=(root) /etc/init.d/${wwwpkgname}
%apache-admin ALL=(root) /bin/su ${wwwuser}, /bin/su - ${wwwuser}
%apache-admin ALL=(root) ${distro_specific_apache_sudo}
",
    require => Group["apache-admin"],
  }

}
