class apache::administration {

  include apache::params

  $distro_specific_apache_sudo = $operatingsystem ? {
    /RedHat|CentOS/ => "/usr/sbin/apachectl, /sbin/service ${apache::params::pkg}",
    /Debian|Ubuntu/ => "/usr/sbin/apache2ctl",
  }

  group { "apache-admin":
    ensure => present,
  }

  # used in erb template
  $wwwpkgname = $apache::params::pkg
  $wwwuser    = $apache::params::user

  common::concatfilepart { "sudoers.apache":
    ensure => present,
    file => "/etc/sudoers",
    content => template("apache/sudoers.apache.erb"),
    require => Group["apache-admin"],
  }

}
