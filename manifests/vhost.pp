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
  $vhostroot="${::apache_c2c::root}/${name}",

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
    false   => "${vhostroot}/htdocs",
    default => $docroot,
  }

  $cgipath = $cgibin ? {
    true    => "${vhostroot}/cgi-bin/",
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
      file { "${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        seltype => $vhost_seltype,
        require => Package[$apache_c2c::params::pkg],
        notify  => Exec['apache-graceful'],
      }

      $docroot_seltype = $::osfamily ? {
        RedHat  => 'httpd_sys_content_t',
        default => undef,
      }
      ensure_resource(
        'file',
        $vhostroot,
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
        "${vhostroot}/conf",
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
        "${vhostroot}/htdocs",
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
        "${vhostroot}/private",
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
        "${vhostroot}/cgi-bin/" => directory,
        default                 => undef,
      }
      $cgidir_path = $cgipath ? {
        false   => "${vhostroot}/cgi-bin/",
        default => $cgipath,
      }
      $cgidir_seltype = $::osfamily ? {
        RedHat  => 'httpd_sys_script_exec_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${vhostroot} cgi-bin directory",
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
        File["${vhostroot}/conf"] {
          source  => $conf_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $htdocs_source {
        File["${vhostroot}/htdocs"] {
          source  => $htdocs_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $private_source {
        File["${vhostroot}/private"] {
          source  => $private_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $cgi_source {
        File["${vhostroot} cgi-bin directory"] {
          source  => $cgi_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
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

      # Log files
      $logdir_seltype = $::osfamily ? {
        RedHat  => 'httpd_log_t',
        default => undef,
      }
      ensure_resource(
        'file',
        "${vhostroot}/logs",
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
          "${vhostroot}/logs/access.log",
          "${vhostroot}/logs/error.log",
        ],
        {
          ensure  => present,
          owner   => root,
          group   => adm,
          mode    => '0644',
          seltype => $logfiles_seltype,
          require => File["${vhostroot}/logs"],
        }
      )

      # README file
      $readme_content = $readme ? {
        false   => template('apache_c2c/README_vhost.erb'),
        default => $readme,
      }
      ensure_resource(
        'file',
        "${vhostroot}/README",
        {
          ensure  => present,
          owner   => root,
          group   => root,
          mode    => '0644',
          content => $readme_content,
        }
      )

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
          File["${vhostroot}/htdocs"],
          File["${vhostroot}/logs"],
          File["${vhostroot}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${priority}-${name}.conf -ef ${apache_c2c::params::conf}/sites-available/${priority}-${name}.conf ]'",
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

      exec { "remove ${vhostroot}":
        command => "rm -rf ${vhostroot}",
        onlyif  => "test -d ${vhostroot}",
        require => Exec["disable vhost ${name}"],
      }

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
}
