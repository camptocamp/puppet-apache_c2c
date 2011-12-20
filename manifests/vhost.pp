define apache::vhost(
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
  $mode=2570,
  $aliases=[],
  $enable_default=true,
  $ports=['*:80'],
  $accesslog_format='combined'
) {

  case $::operatingsystem {

    'redhat', 'CentOS': {
      apache::redhat::vhost{ $name:
        ensure          => $ensure,
        config_file     => $config_file,
        config_content  => $config_content,
        htdocs          => $htdocs,
        conf            => $conf,
        readme          => $readme,
        docroot         => $docroot,
        cgibin          => $cgibin,
        user            => $user,
        admin           => $admin,
        group           => $group,
        mode            => $mode,
        aliases         => $aliases,
        enable_default  => $enable_default,
        ports           => $ports,
        accesslog_format=> $accesslog_format
      }
    }
    'Debian': {
      apache::debian::vhost{ $name:
        ensure          => $ensure,
        config_file     => $config_file,
        config_content  => $config_content,
        htdocs          => $htdocs,
        conf            => $conf,
        readme          => $readme,
        docroot         => $docroot,
        cgibin          => $cgibin,
        user            => $user,
        admin           => $admin,
        group           => $group,
        mode            => $mode,
        aliases         => $aliases,
        enable_default  => $enable_default,
        ports           => $ports,
        accesslog_format=> $accesslog_format
      }
    }
    default: {
      err("no vhost implementation for operating system ${::operatingsystem}")
    }
  }


}