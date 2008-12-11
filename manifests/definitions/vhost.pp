define apache::vhost ($ensure=present, $config_file=false, $config_content=false, $htdocs=false, $conf=false, $user="$wwwuser", $group="root", $mode=2570, $aliases = []) {
  case $ensure {
    present: {
      file { "$wwwconf/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 600,
        seltype => "httpd_config_t",
        require => [Package["$wwwpkgname"], File["$wwwconf/sites-available"]],
        notify  => Service["$wwwpkgname"],
      }

      file {"${wwwroot}/${name}":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
        seltype => "httpd_sys_content_t",
        require => File["${wwwroot}"],
      }

      file {"${wwwroot}/${name}/conf":
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => $mode,
        seltype => "httpd_config_t",
        # BUG: Require fails when using LDAP groups
        #require => [File["${wwwroot}/${name}"], Group[$group]],
        require => [File["${wwwroot}/${name}"]],
      }

      file {"${wwwroot}/${name}/htdocs":
        ensure => directory,
        owner  => $user,
        group  => $group,
        mode   => $mode,
        seltype => "httpd_sys_content_t",
        # BUG: Require fails when using LDAP groups
        #require => [File["${wwwroot}/${name}"], Group[$group]],
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
        owner  => $user,
        group  => $group,
        mode   => $mode,
        seltype => "httpd_sys_script_exec_t",
        # BUG: Require fails when using LDAP groups
        #require => [File["${wwwroot}/${name}"], Group[$group]],
        require => [File["${wwwroot}/${name}"]],
      }

      case $config_file {
        true: {
          File["$wwwconf/sites-available/${name}"] {
            source => "puppet:///$wwwconf/sites-available/${name}",
          }
        }
        false: {

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
        default: {
          fail "Invalid 'source' value '$source' for apache::vhost"
        }
      }

      # Log files
      file {"${wwwroot}/${name}/logs":
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
        seltype => "httpd_log_t",
        require => File["${wwwroot}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${wwwroot}/${name}/logs/access.log", "${wwwroot}/${name}/logs/error.log"] :
        ensure => present,
        owner => root,
        group => adm,
        mode => 644,
        seltype => "httpd_log_t",
        require => File["${wwwroot}/${name}/logs"],
      }

      # Private data
      file {"${wwwroot}/${name}/private":
        ensure  => directory,
        owner   => $user,
        group   => $group,
        mode    => $mode,
        seltype => "httpd_sys_content_t",
        require => File["${wwwroot}/${name}"],
      }

      # README file
      file {"${wwwroot}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 644,
        content => template("apache/README_vhost.erb"),
        require => File["${wwwroot}/${name}"],
      }

      exec {"enable vhost ${name}":
        command => "a2ensite ${name}",
        notify  => Exec["apache-graceful"],
        require => [
          Package["$wwwpkgname"],
          File["$wwwconf/sites-available/${name}"],
          File["$wwwconf/sites-enabled"],
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

      exec { "disable vhost ${name}":
        command => "a2dissite ${name}",
        notify  => Exec["apache-graceful"],
        require => Package["$wwwpkgname"],
        onlyif => "/bin/sh -c '[ -L $wwwconf/sites-enabled/$name ] \\
          && [ $wwwconf/sites-enabled/$name -ef $wwwconf/sites-available/$name ]'",
      }
   }
    default: { err ( "Unknown ensure value: '${ensure}'" ) }
  }
}
