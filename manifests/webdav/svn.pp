define apache::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  $wwwroot = $apache::root
  validate_absolute_path($wwwroot)

  $location = $name

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template('apache/webdav-svn.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
