define apache_c2c::webdav::instance(
  $vhost,
  $ensure    = present,
  $directory = false,
  $mode      = '2755',
) {

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${wwwroot}/${vhost}/private/webdav-${name}"
  }

  $davdir_ensure = $ensure ? {
    present => directory,
    absent  => absent,
  }
  file {$davdir:
    ensure => $davdir_ensure,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => $mode,
  }

  # configuration
  $conffile_seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/webdav-${name}.conf":
    ensure  => $ensure,
    content => template("${module_name}/webdav-config.erb"),
    seltype => $conffile_seltype,
    require => File[$davdir],
    notify  => Exec['apache-graceful'],
  }

}
