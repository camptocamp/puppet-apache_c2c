define apache::vhost (
  $ensure=present,
  $config_file='',
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=true,
  $user='',
  $admin='',
  $group='root',
  $mode='2570',
  $aliases=[],
  $enable_default=true,
  $ports=['*:80'],
  $accesslog_format='combined'
) {

  include apache::params

  $wwwuser = $user ? {
    ''      => $apache::params::user,
    default => $user,
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

  # check if default virtual host is enabled
  if $enable_default == true {

    exec { "enable default virtual host from ${name}":
      command => 'a2ensite default',
      unless  => "test -L ${apache::params::conf}/sites-enabled/000-default",
      notify  => Exec['apache-graceful'],
      require => Package['apache'],
      path    => ['/usr/bin', '/bin', '/usr/local/sbin'],
    }

  } else {

    exec { "disable default virtual host from ${name}":
      command => 'a2dissite default',
      onlyif  => "test -L ${apache::params::conf}/sites-enabled/000-default",
      notify  => Exec['apache-graceful'],
      require => Package['apache'],
    }
  }

  $seltype_config = $::operatingsystem ? {
    redhat  => 'httpd_config_t',
    CentOS  => 'httpd_config_t',
    default => undef,
  }

  $seltype_sys_content = $::operatingsystem ? {
    redhat  => 'httpd_sys_content_t',
    CentOS  => 'httpd_sys_content_t',
    default => undef,
  }

  $seltype_sys_script_exec = $::operatingsystem ? {
    redhat  => 'httpd_sys_script_exec_t',
    CentOS  => 'httpd_sys_script_exec_t',
    default => undef,
  }

  case $ensure {
    present: {
      file { "${apache::params::conf}/sites-available/${name}":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        seltype => $seltype_config,
        require => Package[$apache::params::pkg],
        notify  => Exec['apache-graceful'],
      }

      file { "${apache::params::root}/${name}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $seltype_sys_content,
        require => File['root directory'],
      }

      $confdir_owner = $admin ? {
        ''      => $wwwuser,
        default => $admin,
      }

      file { "${apache::params::root}/${name}/conf":
        ensure  => directory,
        owner   => $confdir_owner,
        group   => $group,
        mode    => $mode,
        seltype => $seltype_config,
        require => [File["${apache::params::root}/${name}"]],
      }

      file { "${apache::params::root}/${name}/htdocs":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $group,
        mode    => $mode,
        seltype => $seltype_sys_content,
        require => [File["${apache::params::root}/${name}"]],
      }

      if $htdocs {
        File["${apache::params::root}/${name}/htdocs"] {
          source  => $htdocs,
          recurse => true,
        }
      }

      if $conf {
        File["${apache::params::root}/${name}/conf"] {
          source  => $conf,
          recurse => true,
        }
      }

      # cgi-bin
      $cgibin_path = $cgipath ? {
        false   => "${apache::params::root}/${name}/cgi-bin/",
        default => $cgipath,
      }

      $cgibin_ensure = $cgipath ? {
        "${apache::params::root}/${name}/cgi-bin/" => directory,
        default                                    => undef, # don't manage this directory unless under $root/$name
      }

      file { "${name} cgi-bin directory":
        ensure  => $cgibin_ensure,
        path    => $cgibin_path,
        owner   => $wwwuser,
        group   => $group,
        mode    => $mode,
        seltype => $seltype_sys_script_exec,
        require => [File["${apache::params::root}/${name}"]],
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
      $logs_seltype = $::operatingsystem ? {
        redhat  => 'httpd_log_t',
        CentOS  => 'httpd_log_t',
        default => undef,
      }

      file {"${apache::params::root}/${name}/logs":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        seltype => $logs_seltype,
        require => File["${apache::params::root}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      $log_files_seltype = $::operatingsystem ? {
        redhat  => 'httpd_log_t',
        CentOS  => 'httpd_log_t',
        default => undef,
      }

      file { ["${apache::params::root}/${name}/logs/access.log",
              "${apache::params::root}/${name}/logs/error.log"] :
        ensure  => present,
        owner   => root,
        group   => adm,
        mode    => '0644',
        seltype => $log_files_seltype,
        require => File["${apache::params::root}/${name}/logs"],
      }

      # Private data
      file {"${apache::params::root}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $group,
        mode    => $mode,
        seltype => $seltype_sys_content,
        require => File["${apache::params::root}/${name}"],
      }

      # README file
      $content_file = $readme ? {
        false   => template('apache/README_vhost.erb'),
        default => $readme,
      }

      file {"${apache::params::root}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => '0644',
        content => $content_file,
        require => File["${apache::params::root}/${name}"],
      }

      $enable_vhost_command = $::operatingsystem ? {
        RedHat  => "/usr/local/sbin/a2ensite ${name}",
        CentOS  => "/usr/local/sbin/a2ensite ${name}",
        default => "/usr/sbin/a2ensite ${name}"
      }

      exec {"enable vhost ${name}":
        command => $enable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => [$::operatingsystem ? {
          redhat  => File['/usr/local/sbin/a2ensite'],
          CentOS  => File['/usr/local/sbin/a2ensite'],
          default => Package[$apache::params::pkg]},
          File["${apache::params::conf}/sites-available/${name}"],
          File["${apache::params::root}/${name}/htdocs"],
          File["${apache::params::root}/${name}/logs"],
          File["${apache::params::root}/${name}/conf"]
        ],
        unless  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
    }

    absent:{
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

      $disable_vhost_command = $::operatingsystem ? {
        RedHat  => "/usr/local/sbin/a2dissite ${name}",
        CentOS  => "/usr/local/sbin/a2dissite ${name}",
        default => "/usr/sbin/a2dissite ${name}"
      }

      $require_disable_vhost = $::operatingsystem ? {
        redhat  => File['/usr/local/sbin/a2ensite'],
        CentOS  => File['/usr/local/sbin/a2ensite'],
        default => Package[$apache::params::pkg]
      }
      exec { "disable vhost ${name}":
        command => $disable_vhost_command,
        notify  => Exec['apache-graceful'],
        require => [$require_disable_vhost],
        onlyif  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
                    && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
    }

    disabled: {
      exec { "disable vhost ${name}":
        command => "a2dissite ${name}",
        notify  => Exec['apache-graceful'],
        require => Package[$apache::params::pkg],
        onlyif  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }

      file { "${apache::params::conf}/sites-enabled/${name}":
        ensure  => absent,
        require => Exec["disable vhost ${name}"]
      }
  }
    default: { err ( "Unknown ensure value: '${ensure}'" ) }
  }
}
