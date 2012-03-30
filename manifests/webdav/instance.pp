define apache::webdav::instance ($vhost, $ensure=present, $directory=false, $mode=2755) {

  include apache::params

  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${apache::params::root}/${vhost}/private/webdav-${name}"
  }

  $ensure_davdir = $ensure ? {
    present => directory,
    absent  => absent,
  }

  file {$davdir:
    ensure => $ensure_davdir,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => $mode,
  }

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  # configuration
  file { "${apache::params::root}/${vhost}/conf/webdav-${name}.conf":
    ensure  => $ensure,
    content => template('apache/webdav-config.erb'),
    seltype => $seltype,
    require => File[$davdir],
    notify  => Exec['apache-graceful'],
  }

}
