define apache::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  include apache::params

  $location = $name

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  file { "${apache::params::root}/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template('apache/webdav-svn.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
