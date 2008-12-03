class apache::administration {

  group { "apache-admin":
    ensure => present,
  }

  $distro_specific_apache_sudo = $operatingsystem ? {
    Debian => "/usr/sbin/apache2ctl",
    RedHat => "/usr/sbin/apachectl, /sbin/service ${wwwpkgname}"
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
