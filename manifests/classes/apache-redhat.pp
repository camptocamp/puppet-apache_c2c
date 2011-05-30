class apache::redhat inherits apache::base {

  include apache::params
  
  # BEGIN inheritance from apache::base
  Exec["apache-graceful"] {
    command => "apachectl graceful",
    onlyif  => "apachectl configtest",
  }

  Package["apache"] {
    require => [File["/usr/local/sbin/a2ensite"], File["/usr/local/sbin/a2dissite"], File["/usr/local/sbin/a2enmod"], File["/usr/local/sbin/a2dismod"]],
  }

  File["logrotate configuration"] { 
    path => "/etc/logrotate.d/httpd",
    source => "puppet:///apache/etc/logrotate.d/httpd",
  }

  File["default status module configuration"] {
    path => "${apache::params::conf}/conf.d/status.conf",
    source => "puppet:///apache/etc/httpd/conf/status.conf",
  }

  File["default virtualhost"] { 
    path => "${apache::params::conf}/sites-available/default",
    content => template("apache/default-vhost.redhat"),
    seltype => "httpd_config_t",
  }  
  # END inheritance from apache::base

  file { ["/usr/local/sbin/a2ensite", "/usr/local/sbin/a2dissite", "/usr/local/sbin/a2enmod", "/usr/local/sbin/a2dismod"]:
    ensure => present,
    mode => 755,
    owner => "root",
    group => "root",
    source => "puppet:///apache/usr/local/sbin/a2X.redhat",
  }

  file { [
      "${apache::params::conf}/sites-available",
      "${apache::params::conf}/sites-enabled",
      "${apache::params::conf}/mods-enabled"
    ]:
    ensure => directory,
    mode => 644,
    owner => "root",
    group => "root",
    seltype => "httpd_config_t",
    require => Package["apache"],
  }

  file { "${apache::params::conf}/conf/httpd.conf":
    ensure => present,
    content => template("apache/httpd.conf.erb"),
    seltype => "httpd_config_t",
    notify  => Service["apache"],
    require => Package["apache"],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  file { "${apache::params::conf}/mods-available":
    ensure => directory,
    source => $lsbmajdistrelease ? {
      5 => "puppet:///apache//etc/httpd/mods-available/redhat5/",
      6 => "puppet:///apache//etc/httpd/mods-available/redhat6/",
    },
    recurse => true,
    mode => 644,
    owner => "root",
    group => "root",
    seltype => "httpd_config_t",
    require => Package["apache"],
  }

  # this module is statically compiled on debian and must be enabled here
  apache::module {["log_config"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

  # no idea why redhat choose to put this file there. apache fails if it's
  # present and mod_proxy isn't...
  file { "${apache::params::conf}/conf.d/proxy_ajp.conf":
    ensure => absent,
    require => Package["apache"],
    notify => Exec["apache-graceful"],
  }

}

