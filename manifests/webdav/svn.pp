define apache_c2c::webdav::svn(
  $ensure,
  $vhost,
  $parent_path,
  $confname,
) {

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $location = $name

  $seltype = $::osfamily ? {
    'RedHat' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template('apache_c2c/webdav-svn.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
