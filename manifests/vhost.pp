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
    false   => "${wwwroot}/${name}/htdocs",
    default => $docroot,
  }

  $cgipath = $cgibin ? {
    true    => "${wwwroot}/${name}/cgi-bin/",
    false   => false,
    default => $cgibin,
  }

  $disable_vhost_command = $::operatingsystem ? {
    RedHat  => "/usr/local/sbin/a2dissite ${name}",
    CentOS  => "/usr/local/sbin/a2dissite ${name}",
    default => "/usr/sbin/a2dissite ${name}"
  }

  case $ensure {
    present: {
      $vhost_seltype = $::operatingsystem ? {
        redhat  => 'httpd_config_t',
        CentOS  => 'httpd_config_t',
        default => undef,
      }
      file { "${apache_c2c::params::conf}/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        seltype => $vhost_seltype,
        require => Package[$apache_c2c::params::pkg],
        notify  => Exec['apache-graceful'],
      }

      $docroot_seltype = $::operatingsystem ? {
        redhat  => 'httpd_sys_content_t',
        CentOS  => 'httpd_sys_content_t',
        default => undef,
      }
      file { "${wwwroot}/${name}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $docroot_seltype,
        require => File['root directory'],
      }

      $confdir_owner = $admin ? {
        ''      => $wwwuser,
        default => $admin,
      }
      $confdir_seltype = $::operatingsystem ? {
        redhat  => 'httpd_config_t',
        CentOS  => 'httpd_config_t',
        default => undef,
      }
      file { "${wwwroot}/${name}/conf":
        ensure  => directory,
        owner   => $confdir_owner,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $confdir_seltype,
        require => [File["${wwwroot}/${name}"]],
      }

      $htdocs_seltype = $::operatingsystem ? {
        redhat  => 'httpd_sys_content_t',
        CentOS  => 'httpd_sys_content_t',
        default => undef,
      }
      file { "${wwwroot}/${name}/htdocs":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $htdocs_seltype,
        require => [File["${wwwroot}/${name}"]],
      }

      # Private data
      $private_seltype = $::operatingsystem ? {
        redhat  => 'httpd_sys_content_t',
        CentOS  => 'httpd_sys_content_t',
        default => undef,
      }
      file {"${wwwroot}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $private_seltype,
        require => File["${wwwroot}/${name}"],
      }

      # cgi-bin
      # don't manage this directory unless under $root/$name
      $cgidir_ensure = $cgipath ? {
        "${wwwroot}/${name}/cgi-bin/" => directory,
        default                       => undef,
      }
      $cgidir_path = $cgipath ? {
        false   => "${wwwroot}/${name}/cgi-bin/",
        default => $cgipath,
      }
      $cgidir_seltype = $::operatingsystem ? {
        redhat  => 'httpd_sys_script_exec_t',
        CentOS  => 'httpd_sys_script_exec_t',
        default => undef,
      }
      file { "${name} cgi-bin directory":
        ensure  => $cgidir_ensure,
        path    => $cgidir_path,
        owner   => $wwwuser,
        group   => $wwwgroup,
        mode    => $mode,
        seltype => $cgidir_seltype,
        require => [File["${wwwroot}/${name}"]],
      }

      if $conf_source {
        File["${wwwroot}/${name}/conf"] {
          source  => $conf_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $htdocs_source {
        File["${wwwroot}/${name}/htdocs"] {
          source  => $htdocs_source,
          recurse => true,
          purge   => true,
          force   => true,
        }
      }

      if $private_source {
        File["${wwwroot}/${name}/private"] {
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
          File["${apache_c2c::params::conf}/sites-available/${name}"] {
            source => $config_file,
          }
        }
        '': {

          if $config_content {
            File["${apache_c2c::params::conf}/sites-available/${name}"] {
              content => $config_content,
            }
          } else {
            # default vhost template
            File["${apache_c2c::params::conf}/sites-available/${name}"] {
              content => template("${module_name}/vhost.erb"),
            }
          }
        }
      }

      # Log files
      $logdir_seltype = $::operatingsystem ? {
        redhat  => 'httpd_log_t',
        CentOS  => 'httpd_log_t',
        default => undef,
      }
      file {"${wwwroot}/${name}/logs":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $logdir_seltype,
        require => File["${wwwroot}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      $logfiles_seltype = $::operatingsystem ? {
        redhat  => 'httpd_log_t',
        CentOS  => 'httpd_log_t',
        default => undef,
      }
      file { ["${wwwroot}/${name}/logs/access.log",
              "${wwwroot}/${name}/logs/error.log"] :
        ensure  => present,
        owner   => root,
        group   => adm,
        mode    => '0644',
        seltype => $logfiles_seltype,
        require => File["${wwwroot}/${name}/logs"],
      }

      # README file
      $readme_content = $readme ? {
        false   => template("${module_name}/README_vhost.erb"),
        default => $readme,
      }
      file {"${wwwroot}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => $readme_content,
        require => File["${wwwroot}/${name}"],
      }

      $enable_vhost_command = $::operatingsystem ? {
        RedHat  => "${apache_c2c::params::a2ensite} ${name}",
        CentOS  => "${apache_c2c::params::a2ensite} ${name}",
        default => "${apache_c2c::params::a2ensite} ${name}"
      }
      exec {"enable vhost ${name}":
        command => $enable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => [
          $::operatingsystem ? {
            redhat  => File[$apache_c2c::params::a2ensite],
            CentOS  => File[$apache_c2c::params::a2ensite],
            default => Package[$apache_c2c::params::pkg]
          },
          File["${apache_c2c::params::conf}/sites-available/${name}"],
          File["${wwwroot}/${name}/htdocs"],
          File["${wwwroot}/${name}/logs"],
          File["${wwwroot}/${name}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${name} -ef ${apache_c2c::params::conf}/sites-available/${name} ]'",
      }
    }

    absent: {
      file { "${apache_c2c::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      file { "${apache_c2c::params::conf}/sites-available/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }

      exec { "remove ${wwwroot}/${name}":
        command => "rm -rf ${wwwroot}/${name}",
        onlyif  => "test -d ${wwwroot}/${name}",
        require => Exec["disable vhost ${name}"],
      }

      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => [$::operatingsystem ? {
          redhat  => File[$apache_c2c::params::a2ensite],
          CentOS  => File[$apache_c2c::params::a2ensite],
          default => Package[$apache_c2c::params::pkg]
          }],
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${name} -ef ${apache_c2c::params::conf}/sites-available/${name} ]'",
      }
    }

    disabled: {
      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => Package[$apache_c2c::params::pkg],
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache_c2c::params::conf}/sites-enabled/${name} -ef ${apache_c2c::params::conf}/sites-available/${name} ]'",
      }

      file { "${apache_c2c::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
    }
    default: { fail ( "Unknown ensure value: '${ensure}'" ) }
  }
}
