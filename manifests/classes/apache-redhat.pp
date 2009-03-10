class apache::base {

      package {"httpd":
        ensure => installed,
        require => [File["/usr/local/sbin/a2ensite"], File["/usr/local/sbin/a2dissite"], File["/usr/local/sbin/a2enmod"], File["/usr/local/sbin/a2dismod"]],
        alias   => "apache2"
      }

      service {"httpd":
        ensure => running,
        enable => true,
        hasrestart => true,
        require => Package["apache2"],
        alias => "apache2"
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

    }


