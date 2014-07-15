define apache_c2c::vhost (
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
  $priority='25',

  $access_log          = undef,
  $additional_includes = undef,
  $directories         = undef,
  $error_log           = undef,
  $log_level           = 'warn',
  $rewrites            = undef,
  $scriptaliases       = undef,
  $servername          = $name,
  $ssl                 = undef,
  $ssl_ca              = undef,
  $ssl_cert            = undef,
  $ssl_certs_dir       = undef,
  $ssl_chain           = undef,
  $ssl_key             = undef,
) {

  include ::apache_c2c::params

  $wwwuser = $user ? {
    ''      => $apache_c2c::params::user,
    default => $user,
  }

  $wwwgroup = $group ? {
    ''      => $apache_c2c::params::group,
    default => $group,
  }

  # used in ERB templates
  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $documentroot = $docroot ? {
    false   => "${::apache_c2c::root}/${servername}/htdocs",
    default => $docroot,
  }

  $cgipath = $cgibin ? {
    true    => "${::apache_c2c::root}/${servername}/cgi-bin/",
    false   => false,
    default => $cgibin,
  }

  $disable_vhost_command = $::osfamily ? {
    RedHat  => "/usr/local/sbin/a2dissite ${priority}-${name}.conf",
    default => "/usr/sbin/a2dissite ${priority}-${name}.conf",
  }

  case $ensure {
    present: {
      $vhost_seltype = $::osfamily ? {
        RedHat  => 'httpd_config_t',
        default => undef,
      }
      file { "${apache_c2c::params::conf}/sites-enabled/${name}":
        ensure => absent,
      }
      if $::apache_c2c::backend != 'puppetlabs' {
        file { "${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf":
          ensure  => present,
          owner   => root,
          group   => root,
          mode    => '0644',
          seltype => $vhost_seltype,
          require => Package[$apache_c2c::params::pkg],
          notify  => Exec['apache-graceful'],
        }
        case $config_file {

          default: {
            File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"] {
              source => $config_file,
            }
          }
          '': {

            if $config_content {
              File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"] {
                content => $config_content,
              }
              } else {
                # default vhost template
                File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"] {
                  content => template('apache_c2c/vhost.erb'),
                }
              }
          }
        }
      }

      $docroot_seltype = $::osfamily ? {
        RedHat  => 'httpd_sys_content_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}",
        {
          ensure  => directory,
          owner   => root,
          group   => root,
          mode    => '0755',
          seltype => $docroot_seltype,
          require => File['root directory'],
        }
      )

      $confdir_owner = $admin ? {
        ''      => $wwwuser,
        default => $admin,
      }
      $confdir_seltype = $::osfamily ? {
        RedHat  => 'httpd_config_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}/conf",
        {
          ensure  => directory,
          owner   => $confdir_owner,
          group   => $wwwgroup,
          mode    => $mode,
          seltype => $confdir_seltype,
        }
      )

      $htdocs_seltype = $::osfamily ? {
        RedHat  => 'httpd_sys_content_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}/htdocs",
        {
          ensure  => directory,
          owner   => $wwwuser,
          group   => $wwwgroup,
          mode    => $mode,
          seltype => $htdocs_seltype,
        }
      )

      # Private data
      $private_seltype = $::osfamily ? {
        RedHat  => 'httpd_sys_content_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}/private",
        {
          ensure  => directory,
          owner   => $wwwuser,
          group   => $wwwgroup,
          mode    => $mode,
          seltype => $private_seltype,
        }
      )

      # cgi-bin
      # don't manage this directory unless under $root/$name
      $cgidir_ensure = $cgipath ? {
        "${::apache_c2c::root}/${servername}/cgi-bin/" => directory,
        default                                        => undef,
      }
      $cgidir_path = $cgipath ? {
        false   => "${::apache_c2c::root}/${servername}/cgi-bin/",
        default => $cgipath,
      }
      $cgidir_seltype = $::osfamily ? {
        RedHat  => 'httpd_sys_script_exec_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername} cgi-bin directory",
        {
          ensure  => $cgidir_ensure,
          path    => $cgidir_path,
          owner   => $wwwuser,
          group   => $wwwgroup,
          mode    => $mode,
          seltype => $cgidir_seltype,
        }
      )

      if $conf_source {
        File["${::apache_c2c::root}/${servername}/conf"] {
          source  => $conf_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $htdocs_source {
        File["${::apache_c2c::root}/${servername}/htdocs"] {
          source  => $htdocs_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $private_source {
        File["${::apache_c2c::root}/${servername}/private"] {
          source  => $private_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $cgi_source {
        File["${::apache_c2c::root}/${servername} cgi-bin directory"] {
          source  => $cgi_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      # Log files
      $logdir_seltype = $::osfamily ? {
        RedHat  => 'httpd_log_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}/logs",
        {
          ensure  => directory,
          owner   => root,
          group   => root,
          mode    => '0755',
          seltype => $logdir_seltype,
        }
      )

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      $logfiles_seltype = $::osfamily ? {
        RedHat  => 'httpd_log_t',
        default => undef,
      }
      ensure_resource(
        'file',
        [
          "${::apache_c2c::root}/${servername}/logs/access.log",
          "${::apache_c2c::root}/${servername}/logs/error.log",
        ],
        {
          ensure  => present,
          owner   => root,
          group   => adm,
          mode    => '0644',
          seltype => $logfiles_seltype,
          require => File["${::apache_c2c::root}/${servername}/logs"],
        }
      )

      # README file
      $readme_content = $readme ? {
        false   => template('apache_c2c/README_vhost.erb'),
        default => $readme,
      }
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}/README",
        {
          ensure  => present,
          owner   => root,
          group   => root,
          mode    => '0644',
          content => $readme_content,
        }
      )

      if $::apache_c2c::backend != 'puppetlabs' {
        $enable_vhost_command = $::osfamily ? {
          RedHat  => "${apache_c2c::params::a2ensite} ${priority}-${name}.conf",
          default => "${apache_c2c::params::a2ensite} ${priority}-${name}.conf"
        }
        exec {"enable vhost ${name}":
          command => $enable_vhost_command,
          notify  => Exec['apache-graceful'],
          require => [
            $::osfamily ? {
              RedHat  => File[$apache_c2c::params::a2ensite],
              default => Package[$apache_c2c::params::pkg]
            },
            File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"],
            File["${::apache_c2c::root}/${servername}/htdocs"],
            File["${::apache_c2c::root}/${servername}/logs"],
            File["${::apache_c2c::root}/${servername}/conf"]
            ],
            unless  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
            && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
        }
      }
    }

    absent: {
      file { "${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      file { "${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      ensure_resource(
        'exec',
        "remove ${::apache_c2c::root}/${servername}",
        {
          command => "rm -rf ${::apache_c2c::root}/${servername}",
          onlyif  => "test -d ${::apache_c2c::root}/${servername}",
          require => Exec["disable vhost ${name}"],
        }
      )

      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => [$::osfamily ? {
          RedHat  => File[$apache_c2c::params::a2ensite],
          default => Package[$apache_c2c::params::pkg]
          }],
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
      }
    }

    disabled: {
      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => Package[$apache_c2c::params::pkg],
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
      }

      file { "${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { fail ( "Unknown ensure value: '${ensure}'" ) }
  }

  if $::apache_c2c::backend == 'puppetlabs' {
    $_additional_includes = $additional_includes ? {
      undef   => "${::apache_c2c::root}/${servername}/conf/*.conf",
      default => $additional_includes,
    }

    $_directories = $directories ? {
      undef   => [
        {
          path        => "${::apache_c2c::root}/${servername}/cgi-bin/",
          options     => ['+ExecCGI',],
          addhandlers => [
            {
              handler    => 'cgi-script',
              extensions => ['.cgi'],
            }
            ],
        },
        ],
        default => $directories,
    }

    $_scriptaliases = $scriptaliases ? {
      undef   => [
        {
          alias => '/cgi-bin/',
          path  => "${::apache_c2c::root}/${servername}/cgi-bin/",
        },
        ],
        default => $scriptaliases,
    }

    $port = split($ports[0], ':')

    apache::vhost { $name:
      ensure              => $ensure,
      access_log          => $access_log,
      access_log_file     => 'access.log',
      additional_includes => $_additional_includes,
      directories         => $_directories,
      docroot             => $documentroot,
      docroot_group       => $wwwgroup,
      docroot_owner       => $wwwuser,
      error_log           => $error_log,
      error_log_file      => 'error.log',
      log_level           => $log_level,
      logroot             => "${::apache_c2c::root}/${servername}/logs",
      port                => $port[1],
      rewrites            => $rewrites,
      scriptaliases       => $_scriptaliases,
      serveraliases       => $aliases,
      servername          => $servername,
      ssl                 => $ssl,
      ssl_ca              => $ssl_ca,
      ssl_cert            => $ssl_cert,
      ssl_certs_dir       => $ssl_certs_dir,
      ssl_chain           => $ssl_chain,
      ssl_key             => $ssl_key,
    }
  }

}
