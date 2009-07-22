class apache::base {

  file {"root directory":
    path => "/var/www",
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"cgi-bin directory":
    path => "/usr/lib/cgi-bin",
    ensure => directory,
    mode => 755,
    owner => "root",
    group => "root",
    require => Package["apache"],
  }

  file {"log directory":
    path => "/var/log/apache2",
    ensure => directory,
    mode => 755,
    owner => "root",
    group  => "root",
    require => Package["apache"],
  }

  file {"logrotate configuration":
    path => "/etc/logrotate.d/apache2",
    ensure => present,
    owner => root,
    group => root,
    mode => 644,
    source => "puppet:///apache/etc/logrotate.d/apache2",
    require => Package["apache"],
  }

  apache::module {["alias", "auth_basic", "authn_file", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "dir", "env", "mime", "negotiation", "rewrite", "setenvif", "status", "cgi"]:
    ensure => present,
    notify => Exec["apache-graceful"],
  }

  file {"default status module configuration":
    path => "/etc/apache2/mods-available/status.conf",
    ensure => present,
    owner => root,
    group => root,
    source => "puppet:///apache/etc/apache2/mods-available/status.conf",
    require => Module["status"],
    notify => Exec["apache-graceful"],
  }

  file {"default virtualhost":
    path => "/etc/apache2/sites-available/default",
    ensure => present,
    source => "puppet:///apache/etc/apache2/sites-available/default",
    require => Package["apache"],
    notify => Exec["apache-graceful"],
    mode => 644,
  }

  exec { "apache-graceful":
    command => "apache2ctl graceful",
    refreshonly => true,
    onlyif => "apache2ctl configtest",
  }

  file {"/usr/local/bin/htgroup":
    ensure => present,
    owner => root,
    group => root,
    mode => 755,
    source => "puppet:///apache/usr/local/bin/htgroup",
  }

}
