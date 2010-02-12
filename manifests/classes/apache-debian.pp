class apache::debian inherits apache::base {

  # BEGIN inheritance from apache::base
  Exec["apache-graceful"] {
    command => "apache2ctl graceful",
    onlyif => "apache2ctl configtest",
  }

  File["log directory"] { path => "/var/log/apache2" }
  File["root directory"] { path => "/var/www" }
  File["cgi-bin directory"] { path => "/usr/lib/cgi-bin" }

  File["logrotate configuration"] {
    path => "/etc/logrotate.d/apache2",
    source => "puppet:///apache/etc/logrotate.d/apache2",
  }

  File["default status module configuration"] {
    path => "/etc/apache2/mods-available/status.conf",
    source => "puppet:///apache/etc/apache2/mods-available/status.conf",
  }

  File["default virtualhost"] {
    path => "/etc/apache2/sites-available/default",
    content => template("apache/default-vhost.debian"),
  }
  # END inheritance from apache::base

  package {"apache2":
    ensure => installed,
    alias  => "apache"
  }

  service {"apache2":
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package["apache"],
    alias => "apache"
  }

  user {"www-data":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache user",
  }

  group {"www-data":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache group",
  }

  package {["apache2-mpm-prefork", "libapache2-mod-proxy-html"]:
    ensure  => installed,
    require => Package["apache"],
  }

  # directory not present in lenny
  file {"/var/www/apache2-default":
    ensure  => absent,
    force => true,
  }

  file {"/var/www/index.html":
    ensure => absent,
  }

  file {"/var/www/html":
    ensure => directory,
    require => File["/var/www"],
  }

  file {"/var/www/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    content => "<html><body><h1>It works!</h1></body></html>\n",
    require => File["/var/www/html"],
  }

  file {"/etc/apache2/conf.d/servername.conf":
    content => "ServerName ${fqdn}\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

  common::concatfilepart {"apache.ports":
    ensure  => present,
    file    => "/etc/apache2/ports.conf",
    content => template("apache/ports.conf.erb"),
    require => Package["apache"],
    notify  => Service["apache"],
  }

  file {"/etc/apache2/sites-available/default-ssl":
    ensure => absent,
    force => true,
  }

}
