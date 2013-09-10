define apache::vhost (
  $ensure=present,
  $config_file='',
  $config_content=false,
  $htdocs_source=false,
  $conf_source=false,
  $cgi_source=false,
  $private_source=false,
  $readme=false,
  $docroot=false,
  $cgibin=true,
  $user='',
  $admin='',
  $group='',
  $mode='2570',
  $aliases=[],
  $ports=['*:80'],
  $accesslog_format='combined',
) {

  include ::apache::params

  $wwwuser = $user ? {
    ''      => $apache::params::user,
    default => $user,
  }

  $wwwgroup = $group ? {
    ''      => $apache::params::group,
    default => $group,
  }

  # used in ERB templates
  $wwwroot = $apache::params::root

  $documentroot = $docroot ? {
    false   => "${wwwroot}/${name}/htdocs",
    default => $docroot,
  }

  $cgipath = $cgibin ? {
    true    => "${wwwroot}/${name}/cgi-bin/",
    false   => false,
    default => $cgibin,
  }

  case $ensure {
    present: {
      file { "${apache::params::conf}/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_config_t',
          CentOS  => 'httpd_config_t',
          default => undef,
        },
        require => Package[$apache::params::pkg],
        notify  => Exec['apache-graceful'],
      }

      file { "${apache::params::root}/${name}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_sys_content_t',
          CentOS  => 'httpd_sys_content_t',
          default => undef,
        },
        require => File['root directory'],
      }

      file { "${apache::params::root}/${name}/conf":
        ensure  => directory,
        owner   => $admin ? {
          ''      => $wwwuser,
          default => $admin,
        },
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_config_t',
          CentOS  => 'httpd_config_t',
          default => undef,
        },
        require => [File["${apache::params::root}/${name}"]],
      }

      file { "${apache::params::root}/${name}/htdocs":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_sys_content_t',
          CentOS  => 'httpd_sys_content_t',
          default => undef,
        },
        require => [File["${apache::params::root}/${name}"]],
      }

      # Private data
      file {"${apache::params::root}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_sys_content_t',
          CentOS  => 'httpd_sys_content_t',
          default => undef,
        },
        require => File["${apache::params::root}/${name}"],
      }

      # cgi-bin
      file { "${name} cgi-bin directory":
        ensure  => $cgipath ? {
          "${apache::params::root}/${name}/cgi-bin/" => directory,
          default                                    => undef, # don't manage this directory unless under $root/$name
        },
        path    => $cgipath ? {
          false   => "${apache::params::root}/${name}/cgi-bin/",
          default => $cgipath,
        },
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_sys_script_exec_t',
          CentOS  => 'httpd_sys_script_exec_t',
          default => undef,
        },
        require => [File["${apache::params::root}/${name}"]],
      }

      if $conf_source {
        File["${apache::params::root}/${name}/conf"] {
          source  => $conf_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $htdocs_source {
        File["${apache::params::root}/${name}/htdocs"] {
          source  => $htdocs_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $private_source {
        File["${apache::params::root}/${name}/private"] {
          source  => $private_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $cgi_source {
        File["${name} cgi-bin directory"] {
          source  => $cgi_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      case $config_file {

        default: {
          File["${apache::params::conf}/sites-available/${name}"] {
            source => $config_file,
          }
        }
        '': {

          if $config_content {
            File["${apache::params::conf}/sites-available/${name}"] {
              content => $config_content,
            }
          } else {
            # default vhost template
            File["${apache::params::conf}/sites-available/${name}"] {
              content => template('apache/vhost.erb'),
            }
          }
        }
      }

      # Log files
      file {"${apache::params::root}/${name}/logs":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_log_t',
          CentOS  => 'httpd_log_t',
          default => undef,
        },
        require => File["${apache::params::root}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${apache::params::root}/${name}/logs/access.log",
              "${apache::params::root}/${name}/logs/error.log"] :
        ensure  => present,
        owner   => root,
        group   => adm,
        mode    => '0644',
        seltype => $::operatingsystem ? {
          redhat  => 'httpd_log_t',
          CentOS  => 'httpd_log_t',
          default => undef,
        },
        require => File["${apache::params::root}/${name}/logs"],
      }

      # README file
      file {"${apache::params::root}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => $readme ? {
          false   => template('apache/README_vhost.erb'),
          default => $readme,
        },
        require => File["${apache::params::root}/${name}"],
      }

      exec {"enable vhost ${name}":
        command => $::operatingsystem ? {
          RedHat  => "${apache::params::a2ensite} ${name}",
          CentOS  => "${apache::params::a2ensite} ${name}",
          default => "${apache::params::a2ensite} ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [
          $::operatingsystem ? {
            redhat  => File[$apache::params::a2ensite],
            CentOS  => File[$apache::params::a2ensite],
            default => Package[$apache::params::pkg]
          },
          File["${apache::params::conf}/sites-available/${name}"],
          File["${apache::params::root}/${name}/htdocs"],
          File["${apache::params::root}/${name}/logs"],
          File["${apache::params::root}/${name}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
    }

    absent: {
      file { "${apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      file { "${apache::params::conf}/sites-available/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      exec { "remove ${apache::params::root}/${name}":
        command => "rm -rf ${apache::params::root}/${name}",
        onlyif  => "test -d ${apache::params::root}/${name}",
        require => Exec["disable vhost ${name}"],
      }

      exec { "disable vhost ${name}":
        command => $::operatingsystem ? {
          RedHat  => "/usr/local/sbin/a2dissite ${name}",
          CentOS  => "/usr/local/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [$::operatingsystem ? {
          redhat => File[$apache::params::a2ensite],
          CentOS => File[$apache::params::a2ensite],
          default => Package[$apache::params::pkg]
          }],
          onlyif => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
            && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
    }

    disabled: {
      exec { "disable vhost ${name}":
        command => $::operatingsystem ? {
          RedHat => "/usr/local/sbin/a2dissite ${name}",
          CentOS => "/usr/local/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => Package[$apache::params::pkg],
        onlyif => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }

      file { "${apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { fail ( "Unknown ensure value: '${ensure}'" ) }
  }
}
