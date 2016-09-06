define apache_c2c::vhost (
  $ensure         = present,
  $config_content = false,
  $readme         = false,
  $docroot        = false,
  $cgibin         = true,
  $config_file    = undef,
  # lint:ignore:empty_string_assignment
  $user           = '',
  $admin          = '',
  $group          = '',
  # lint:endignore
  $mode           = '2570',
  $aliases        = [],
  $ports          = ['*:80'],
  $sslports       = ['*:443'],
  $priority       = '25',
  $options        = [],

  $access_log          = undef,
  $additional_includes = undef,
  $accesslog_format    = undef,
  $directories         = undef,
  $error_log           = undef,
  $log_level           = 'warn',
  $rewrites            = undef,
  $scriptaliases       = undef,
  $servername          = $name,
  $ssl                 = undef,
  $ssl_ca              = $::osfamily ? {
    'RedHat' => '/etc/pki/tls/certs/ca-bundle.crt',
    'Debian' => '/etc/ssl/certs/ca-certificates.crt',
  },
  $ssl_cert            = undef,
  $ssl_certs_dir       = undef,
  $ssl_chain           = undef,
  $ssl_crl             = undef,
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
    'RedHat' => "/usr/local/sbin/a2dissite ${priority}-${name}.conf",
    default  => "/usr/sbin/a2dissite ${priority}-${name}.conf",
  }

  # Set access log format
  if $accesslog_format {
    $_accesslog_format = "\"${accesslog_format}\""
  } else {
    $_accesslog_format = 'combined'
  }

  case $ensure {
    'present': {
      $vhost_seltype = 'httpd_config_t'
      file { "${apache_c2c::params::conf}/sites-enabled/${name}":
        ensure => absent,
      }
      if $::apache_c2c::backend != 'puppetlabs' {
        file { "${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf":
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0644',
          seltype => $vhost_seltype,
          require => Package['httpd'],
          notify  => Exec['apache-graceful'],
        }
        if $config_file {
          File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"] {
            source => $config_file,
          }
        } else {
          if $config_content {
            File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"] {
              content => $config_content,
            }
          } else {
            if $ssl {
              $_config_content = template('apache_c2c/vhost-ssl.erb')
            } elsif $rewrites != undef {
              $_config_content = template('apache_c2c/vhost-redirect-ssl.erb')
            } else {
              $_config_content = template('apache_c2c/vhost.erb')
            }
            # default vhost template
            File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"] {
              content => $_config_content,
            }
          }
        }
      }

      $docroot_seltype = 'httpd_sys_content_t'
      ensure_resource(
        'file',
        "${::apache_c2c::root}/${servername}",
        {
          ensure  => directory,
          owner   => root,
          group   => root,
          mode    => '0755',
          seltype => $docroot_seltype,
          require => File[$wwwroot],
        }
      )

      $confdir_owner = $admin ? {
        ''      => $wwwuser,
        default => $admin,
      }
      $confdir_seltype = 'httpd_config_t'
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

      $htdocs_seltype ='httpd_sys_content_t'
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
      $private_seltype ='httpd_sys_content_t'
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
      $cgidir_seltype = 'httpd_sys_script_exec_t'
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

      # Log files
      $logdir_seltype = 'httpd_log_t'
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
      $logfiles_seltype = 'httpd_log_t'
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
          'RedHat' => "${apache_c2c::params::a2ensite} ${priority}-${name}.conf",
          default  => "${apache_c2c::params::a2ensite} ${priority}-${name}.conf"
        }
        exec {"enable vhost ${name}":
          command  => $enable_vhost_command,
          notify   => Exec['apache-graceful'],
          require  => [
            $::osfamily ? {
              'RedHat' => File[$apache_c2c::params::a2ensite],
              default  => Package['httpd']
            },
            File["${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf"],
            File["${::apache_c2c::root}/${servername}/htdocs"],
            File["${::apache_c2c::root}/${servername}/logs"],
            File["${::apache_c2c::root}/${servername}/conf"]
            ],
            unless => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
            && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
        }
      }
    }

    'absent': {
      file { "${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf":
        ensure  => absent,
        require => Exec["disable vhost ${name}"],
      }

      file { "${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf":
        ensure  => absent,
        require => Exec["disable vhost ${name}"],
      }

      ensure_resource(
        'exec',
        "remove ${::apache_c2c::root}/${servername}",
        {
          command => "rm -rf ${::apache_c2c::root}/${servername}",
          onlyif  => "test -d ${::apache_c2c::root}/${servername}",
        }
      )

      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        before  => Exec["remove ${::apache_c2c::root}/${servername}"],
        require => [$::osfamily ? {
          'RedHat' => File[$apache_c2c::params::a2ensite],
          default  => Package['httpd']
          }],
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
      }
    }

    'disabled': {
      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => Package['httpd'],
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
      }

      file { "${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf":
        ensure  => absent,
        require => Exec["disable vhost ${name}"],
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
          'path'        => "${::apache_c2c::root}/${servername}/cgi-bin/",
          'options'     => ['+ExecCGI',],
          'addhandlers' => [
            {
              'handler'    => 'cgi-script',
              'extensions' => ['.cgi'],
            }
            ],
        },
        ],
        default => $directories,
    }

    $_scriptaliases = $scriptaliases ? {
      undef   => [
        {
          'alias' => '/cgi-bin/',
          'path'  => "${::apache_c2c::root}/${servername}/cgi-bin/",
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
      ssl_crl             => $ssl_crl,
      ssl_key             => $ssl_key,
    }
  }

}
