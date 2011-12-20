define apache::debian::vhost (
  $ensure=present,
  $config_file=undef,
  $config_content=undef,
  $htdocs=undef,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=undef,
  $user="",
  $admin="",
  $group="root",
  $mode=2570,
  $aliases=[],
  $enable_default=true,
  $ports=['*:80'],
  $accesslog_format="combined"
) {

  # make sure we have access to the params
  include apache::params

#== configuration parameters 

  # no cgibin support for debian, feel free to implement!  
  if $cgibin != undef {
    err('cgi support for debian is missing')
  }

  # what user do we run under?
  $wwwuser = $user ? {
    ""      => $apache::params::user,
    default => $user,
  }

  # the apache webroot
  $wwwroot = $apache::params::root

  # the docroot of this vhost
  $documentroot = $docroot ? {
    false   => "${wwwroot}/${name}/htdocs",
    default => $docroot,
  }

  # the htdocs for this vhost
  $htdocs_real = $htdocs ? {
    undef   => "${apache::params::root}/${name}/htdocs",
    default => $htdocs 
  }

  $config_content_real = $config_content ? {
    undef     => undef,
    'default' => template('apache/vhost.erb'),
    default   => $config_content
  }

  $config_file_real = $config_file ? {
    undef     => undef,
    default   => $config_file
  }

  if $config_file_real and $config_content_real {
    err("cannot both set config file and config file content at apache::debian::vhost $name")
  }
#== declaring resources

  case $ensure {
    present: {
      file { "${apache::params::conf}/sites-available/${name}.conf":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 0644,
        source  => $config_file_real,
        content => $config_content_real,
        require => Package[$apache::params::pkg],
        notify  => Exec["apache-graceful"],
      }

      file { "${apache::params::root}/${name}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 0755,
        require => File["root directory"],
      }

      file { $htdocs_real:
        ensure  => directory,
        owner   => $wwwuser,
        group   => $group,
        mode    => $mode,
        require => [File["${apache::params::root}/${name}"]],
      }

      # Log files
      file {"${apache::params::root}/${name}/logs":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 0755,
        require => File["${apache::params::root}/${name}"],
      }

      # We have to give log files to right people with correct rights on them.
      # Those rights have to match those set by logrotate
      file { ["${apache::params::root}/${name}/logs/access.log",
              "${apache::params::root}/${name}/logs/error.log"] :
        ensure   => present,
        owner    => root,
        group    => adm,
        mode     => 0644,
        require  => File["${apache::params::root}/${name}/logs"],
      }

      # Private data
      file {"${apache::params::root}/${name}/private":
        ensure  => directory,
        owner   => $wwwuser,
        group   => $group,
        mode    => $mode,
        require => File["${apache::params::root}/${name}"],
      }

      # README file
      file {"${apache::params::root}/${name}/README":
        ensure  => present,
        owner   => root,
        group   => root,
        mode    => 0644,
        content => $readme ? {
          false   => template("apache/README_vhost.erb"),
          default => $readme,
        },
        require => File["${apache::params::root}/${name}"],
      }

      exec {"enable vhost ${name}":
        command => "/usr/sbin/a2ensite ${name}",
        notify  => Exec["apache-graceful"],
        require => [
          Package[$apache::params::pkg],
          File["${apache::params::conf}/sites-available/${name}"],
          File["${apache::params::root}/${name}/htdocs"],
          File["${apache::params::root}/${name}/logs"],
        ],
        unless  => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
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

      exec { "disable vhost ${name}":
        command   => $::operatingsystem ? {
          RedHat  => "/usr/local/sbin/a2dissite ${name}",
          CentOS  => "/usr/local/sbin/a2dissite ${name}",
          Debian  => "/usr/sbin/a2dissite ${name}",
          default => "/usr/sbin/a2dissite ${name}"
        },
        notify  => Exec["apache-graceful"],
        require => [$::operatingsystem ? {
          redhat => File["/usr/local/sbin/a2ensite"],
          CentOS => File["/usr/local/sbin/a2ensite"],
          default => Package[$apache::params::pkg]}],
        onlyif => "/bin/sh -c '[ -L ${apache::params::conf}/sites-enabled/${name} ] \\
          && [ ${apache::params::conf}/sites-enabled/${name} -ef ${apache::params::conf}/sites-available/${name} ]'",
      }
   }

   disabled: {
      exec { "disable vhost ${name}":
        command => "a2dissite ${name}",
        notify  => Exec["apache-graceful"],
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
