define apache_c2c::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $location = $name

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("${module_name}/webdav-svn.erb"),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
