define apache::vhost (
  $ensure=present,
  $config_file="",
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $user="",
  $admin="",
  $group="root",
  $mode=2570,
  $aliases=[],
  $enable_default=true,
  $ports=['*:80']
) {

  case $operatingsystem {
    redhat,CentOS : {
      $wwwuser =  $user ? {
        "" => "apache",
        default => $user,
      }
      $wwwconf = "/etc/httpd"
      $wwwpkgname = "httpd"
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwuser =  $user ? {
        "" => "www-data",
        default => $user,
      }
      $wwwconf = "/etc/apache2"
      $wwwpkgname = "apache2"
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }    

  # check if default virtual host is enabled
  if $enable_default == true {

    exec { "enable default virtual host from ${name}":
      command => "a2ensite default",
      unless  => "test -L ${wwwconf}/sites-enabled/000-default",
      notify  => Exec["apache-graceful"],
      require => Package["apache"],
    }

  } else {

    exec { "disable default virtual host from ${name}":
      command => "a2dissite default",
      onlyif  => "test -L ${wwwconf}/sites-enabled/000-default",
      notify  => Exec["apache-graceful"],
      require => Package["apache"],
    }
  }

  case $ensure {
    present: {
      file { "$wwwconf/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        seltype => $operatingsystem ? {
          redhat => "httpd_config_t",
          CentOS => "httpd_config_t",
          default => undef,
        },
        require => Package["$wwwpkgname"],
        notify  => Exec["apache-graceful"],
      }

      file {"${wwwroot}/${name}":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_content_t",
          CentOS => "httpd_sys_content_t",
          default => undef,
        },
        require => File["root directory"],
      }

      file {"${wwwroot}/${name}/conf":
        ensure => directory,
        owner  => $admin ? {
          "" => $wwwuser,
          default => $admin,
        },
        group  => $group,
        mode   => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_config_t",
          CentOS => "httpd_config_t",
          default => undef,
        },
        require => [File["${wwwroot}/${name}"]],
      }

      file {"${wwwroot}/${name}/htdocs":
        ensure => directory,
        owner  => $wwwuser,
        group  => $group,
        mode   => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_content_t",
          CentOS => "httpd_sys_content_t",
          default => undef,
        },
        require => [File["${wwwroot}/${name}"]],
      }
 
      if $htdocs {
        File["${wwwroot}/${name}/htdocs"] {
          source  => $htdocs,
          recurse => true,
        }
      }

      if $conf {
        File["${wwwroot}/${name}/conf"] {
          source  => $conf,
          recurse => true,
        }
      }

      # cgi-bin
      file {"${wwwroot}/${name}/cgi-bin":
        ensure => directory,
        owner  => $wwwuser,
        group  => $group,
        mode   => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_script_exec_t",
          CentOS => "httpd_sys_script_exec_t",
          default => undef,
        },
        require => [File["${wwwroot}/${name}"]],
      }

      case $config_file {

        default: {
          File["$wwwconf/sites-available/${name}"] {
            source => $config_file,
          }
        }
        "": {

          if $config_content {
            File["$wwwconf/sites-available/${name}"] {
              content => $config_content,
            }
          } else {
            # default vhost template
            File["$wwwconf/sites-available/${name}"] {
              content => template("apache/vhost.erb"), 
            }
          }
        }
      }

      # Log files
      file {"${wwwroot}/${name}/logs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
        seltype => $operatingsystem ? {
          redhat => "httpd_log_t",
          CentOS => "httpd_log_t",
          default => undef,
        },
        require => File["${wwwroot}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${wwwroot}/${name}/logs/access.log", "${wwwroot}/${name}/logs/error.log"] :
        ensure => present,
        owner => root,
        group => adm,
        mode => 644,
        seltype => $operatingsystem ? {
          redhat => "httpd_log_t",
          CentOS => "httpd_log_t",
          default => undef,
        },
        require => File["${wwwroot}/${name}/logs"],
      }

      # Private data
      file {"${wwwroot}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $group,
        mode    => $mode,
        seltype => $operatingsystem ? {
          redhat => "httpd_sys_content_t",
          CentOS => "httpd_sys_content_t",
          default => undef,
        },
        require => File["${wwwroot}/${name}"],
      }

      # README file
      file {"${wwwroot}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => $readme ? {
          false => template("apache/README_vhost.erb"),
          default => $readme,
        },
        require => File["${wwwroot}/${name}"],
      }

      exec {"enable vhost ${name}":
        command => $operatingsystem ? {
          RedHat => "/usr/local/sbin/a2ensite ${name}",
          CentOS => "/usr/local/sbin/a2ensite ${name}",
          default => "/usr/sbin/a2ensite ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [$operatingsystem ? {
          redhat => File["/usr/local/sbin/a2ensite"],
          CentOS => File["/usr/local/sbin/a2ensite"],
          default => Package["$wwwpkgname"]},
          File["$wwwconf/sites-available/${name}"],
          File["${wwwroot}/${name}/htdocs"],
          File["${wwwroot}/${name}/logs"],
          File["${wwwroot}/${name}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L $wwwconf/sites-enabled/$name ] \\
          && [ $wwwconf/sites-enabled/$name -ef $wwwconf/sites-available/$name ]'",
      }
    }

    absent:{
      file { "$wwwconf/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
      
      file { "$wwwconf/sites-available/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      exec {"remove ${wwwroot}/${name}":
        command => "rm -rf ${wwwroot}/${name}",
        onlyif  => "test -d ${wwwroot}/${name}",
        require => Exec["disable vhost ${name}"],
      }

      exec { "disable vhost ${name}":
        command => $operatingsystem ? {
          RedHat => "/usr/local/sbin/a2dissite ${name}",
          CentOS => "/usr/local/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [$operatingsystem ? {
          redhat => File["/usr/local/sbin/a2ensite"],
          CentOS => File["/usr/local/sbin/a2ensite"],
          default => Package["$wwwpkgname"]}],
        onlyif => "/bin/sh -c '[ -L $wwwconf/sites-enabled/$name ] \\
          && [ $wwwconf/sites-enabled/$name -ef $wwwconf/sites-available/$name ]'",
      }
   }

   disabled: {
      exec { "disable vhost ${name}":
        command => "a2dissite ${name}",
        notify  => Exec["apache-graceful"],
        require => Package["$wwwpkgname"],
        onlyif => "/bin/sh -c '[ -L $wwwconf/sites-enabled/$name ] \\
          && [ $wwwconf/sites-enabled/$name -ef $wwwconf/sites-available/$name ]'",
      }

      file { "$wwwconf/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { err ( "Unknown ensure value: '${ensure}'" ) }
  }
}
