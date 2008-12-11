class apache::base {

  case $operatingsystem {

    RedHat: {

      package { "httpd":
        ensure => installed,
        require => [File["/usr/local/sbin/a2ensite"], File["/usr/local/sbin/a2dissite"], File["/usr/local/sbin/a2enmod"], File["/usr/local/sbin/a2dismod"]],
      }

      file { "/var/log/httpd":
        ensure  => directory,
        mode    => 755,
        owner   => "root",
        group   => "root",
        require => Package["$wwwpkgname"],
      }

      file { ["/usr/local/sbin/a2ensite", "/usr/local/sbin/a2dissite", "/usr/local/sbin/a2enmod", "/usr/local/sbin/a2dismod"]:
        ensure => present,
        mode => 755,
        owner => "root",
        group => "root",
        source => "puppet:///apache/usr/local/sbin/a2X.redhat",
      }

      file { ["$wwwconf/sites-available", "$wwwconf/sites-enabled", "$wwwconf/mods-enabled"]:
        ensure  => directory,
        mode    => 644,
        owner   => "root",
        group   => "root",
        seltype => "httpd_config_t",
        require => Package["$wwwpkgname"],
      }

      file { "$wwwconf/conf/httpd.conf":
        ensure => present,
        source => "puppet:///apache/$wwwconf/conf/httpd.conf",
        seltype => "httpd_config_t",
        notify  => Service["$wwwpkgname"],
        require => Package["$wwwpkgname"],
      }

      # the following command was used to generate the content of the directory:
      # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
      file {"$wwwconf/mods-available":
        ensure  => directory,
        source  => $lsbmajdistrelease ? {
          5 => "puppet:///apache/${wwwconf}/mods-available/redhat5/",
        },
        recurse => true,
        mode    => 755,
        owner   => "root",
        group   => "root",
        seltype => "httpd_config_t",
        require => Package["$wwwpkgname"],
      }

      # this module is statically compiled on debian and must be enabled here
      apache::module {["log_config"]:
        ensure => present,
        notify  => Exec["apache-graceful"],
        require => [File["$wwwconf/mods-available"], File["$wwwconf/mods-enabled"]],
      }

      # no idea why redhat choose to put this file there. apache fails if it's
      # present and mod_proxy isn't...
      file { "$wwwconf/conf.d/proxy_ajp.conf":
        ensure => absent,
        require => Package["$wwwpkgname"],
        notify => Exec["apache-graceful"],
      }

    } # end Redhat

    Debian: {

      package { ["apache2", "apache2-mpm-prefork", "libapache2-mod-proxy-html"]:
        ensure => installed
      }

      file { "${wwwconf}/mods-available":
        source  => "puppet:///apache/${wwwconf}/mods-available",
        recurse => true,
        require => Package["$wwwpkgname"],
      }

      file { ["${wwwconf}/mods-enabled", "${wwwconf}/sites-available", "${wwwconf}/sites-enabled"]:
        ensure => directory,
        require => Package["$wwwpkgname"],
      }

    } # end Debian

  }

  user { "$wwwuser":
    ensure  => present,
    require => Package["$wwwpkgname"],
  }

  group { "$wwwuser":
    ensure  => present,
    require => Package["$wwwpkgname"],
  }

  service { "$wwwpkgname":
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package["$wwwpkgname"],
  }

  file {"$wwwroot":
    ensure  => directory,
    mode    => 755,
    owner   => "root",
    group   => "root",
    seltype => "httpd_sys_content_t",
    require => Package["$wwwpkgname"],
  }

  file {"$wwwcgi":
    ensure  => directory,
    mode    => 755,
    owner   => "root",
    group   => "root",
    seltype => "httpd_sys_script_exec_t",
    require => Package["$wwwpkgname"],
  }

  file {"/etc/logrotate.d/$wwwpkgname":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 644,
    source  => "puppet:///apache/etc/logrotate.d/$wwwpkgname",
    require => Package["$wwwpkgname"],
  }

  # these are the modules enabled by default on debian/lenny.
  apache::module {["alias", "auth_basic", "authn_file", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "deflate", "dir", "env", "mime", "negotiation", "rewrite", "setenvif", "status"]:
    ensure => present,
    notify  => Exec["apache-graceful"],
    require => [File["$wwwconf/mods-available"], File["$wwwconf/mods-enabled"], File["$wwwconf/sites-available"], File["$wwwconf/sites-enabled"]],
  }

  # this module is needed by default in our config.
  apache::module {["cgi"]:
    ensure => present,
    notify  => Exec["apache-graceful"],
    require => [File["$wwwconf/mods-available"], File["$wwwconf/mods-enabled"], File["$wwwconf/sites-available"], File["$wwwconf/sites-enabled"]],
  }

  file { "${wwwconf}/sites-available/default":
    ensure  => present,
    source  => "puppet:///apache/${wwwconf}/sites-available/default",
    seltype => "httpd_config_t",
    require => Package["$wwwpkgname"],
    notify  => Exec["apache-graceful"],
    mode    => 644,
  }

  file { "${wwwconf}/sites-enabled/000-default":
    ensure => "${wwwconf}/sites-available/default",
    seltype => "httpd_config_t",
    require => [Package["$wwwpkgname"], File["${wwwconf}/sites-available/default"]],
    notify  => Exec["apache-graceful"],
  }

  exec { "apache-graceful":
    command => $operatingsystem ? {
      Debian => "apache2ctl graceful",
      RedHat => "apachectl graceful",
    },
    refreshonly => true,
    onlyif => $operatingsystem ? {
      Debian => "apache2ctl configtest",
      RedHat => "apache2ctl configtest",
    },
  }

}
