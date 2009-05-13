class apache::redhat inherits apache::base {
  
  # BEGIN inheritance from apache::base
  Exec["apache-graceful"] {
    command => "apachectl graceful",
    onlyif => "apachectl configtest",
  }

  File["log directory"] { path => "/var/log/httpd" }
  File["root directory"] { path => "/var/www/vhosts" }
  File["cgi-bin directory"] { path => "/var/www/cgi-bin" }
  
  File["enable default virtualhost"] { 
    ensure => "/etc/httpd/sites-available/default",
    path => "/etc/httpd/sites-enabled/000-default",
  }

  File["logrotate configuration"] { 
    path => "/etc/logrotate.d/httpd",
    source => "puppet:///apache/etc/logrotate.d/httpd",
  }
  
  File["default virtualhost"] { 
    path => "/etc/httpd/sites-available/default",
    source => "puppet:///apache/etc/httpd/sites-available/default",
    seltype => "httpd_config_t",
  }  
  # END inheritance from apache::base

  package {"httpd":
    ensure => installed,
    require => [File["/usr/local/sbin/a2ensite"], File["/usr/local/sbin/a2dissite"], File["/usr/local/sbin/a2enmod"], File["/usr/local/sbin/a2dismod"]],
    alias => "apache"
  }

  service {"httpd":
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package["apache"],
    alias => "apache"
  }

  user { "apache":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache user",
  }

  group { "apache":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache group",
  }

  file { ["/usr/local/sbin/a2ensite", "/usr/local/sbin/a2dissite", "/usr/local/sbin/a2enmod", "/usr/local/sbin/a2dismod"]:
    ensure => present,
    mode => 755,
    owner => "root",
    group => "root",
    source => "puppet:///apache/usr/local/sbin/a2X.redhat",
  }

  file { ["/etc/httpd/sites-available", "/etc/httpd/sites-enabled", "/etc/httpd/mods-enabled"]:
    ensure => directory,
    mode => 644,
    owner => "root",
    group => "root",
    seltype => "httpd_config_t",
    require => Package["apache"],
  }

  file { "/etc/httpd/conf/httpd.conf":
    ensure => present,
    source => "puppet:///apache/etc/httpd/conf/httpd.conf",
    seltype => "httpd_config_t",
    notify  => Service["apache"],
    require => Package["apache"],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  file {"/etc/httpd/mods-available":
    ensure => directory,
    source => $lsbmajdistrelease ? {
      5 => "puppet:///apache//etc/httpd/mods-available/redhat5/",
    },
    recurse => true,
    mode => 755,
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
  file {"/etc/httpd/conf.d/proxy_ajp.conf":
    ensure => absent,
    require => Package["apache"],
    notify => Exec["apache-graceful"],
  }

}

