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

  # $httpd_pid_file is used in template logrotate-httpd.erb
  $httpd_pid_file = $lsbmajdistrelease ? {
    /4|5/   => "/var/run/httpd.pid",
    default => "/var/run/httpd/httpd.pid",
  }
  File["logrotate configuration"] { 
    path    => "/etc/logrotate.d/httpd",
    content => template("apache/logrotate-httpd.erb"),
  }

  File["default status module configuration"] {
    path => "${apache::params::conf}/conf.d/status.conf",
    source => "puppet:///modules/apache/etc/httpd/conf/status.conf",
  }

  File["default virtualhost"] { 
    seltype => "httpd_config_t",
  }  
  # END inheritance from apache::base

  file { ["/usr/local/sbin/a2ensite", "/usr/local/sbin/a2dissite", "/usr/local/sbin/a2enmod", "/usr/local/sbin/a2dismod"]:
    ensure => present,
    mode => 755,
    owner => "root",
    group => "root",
    source => "puppet:///modules/apache/usr/local/sbin/a2X.redhat",
  }

  $httpd_mpm = $apache_mpm_type ? {
    ''         => 'httpd', # default MPM
    'pre-fork' => 'httpd',
    'prefork'  => 'httpd',
    default    => "httpd.${apache_mpm_type}",
  }

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/${httpd_mpm}",
    require => Package["apache"],
    notify  => Service["apache"],
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
      5 => "puppet:///modules/apache/etc/httpd/mods-available/redhat5/",
      6 => "puppet:///modules/apache/etc/httpd/mods-available/redhat6/",
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

  # it makes no sens to put CGI here, deleted from the default vhost config
  file {"/var/www/cgi-bin":
    ensure  => absent,
    require => Package["apache"],
  }

  # no idea why redhat choose to put this file there. apache fails if it's
  # present and mod_proxy isn't...
  file { "${apache::params::conf}/conf.d/proxy_ajp.conf":
    ensure => absent,
    require => Package["apache"],
    notify => Exec["apache-graceful"],
  }

}

