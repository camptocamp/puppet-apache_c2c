define apache::userdirinstance ($vhost, $ensure=present) {

  include apache::params

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }

  file { "${apache::params::root}/${vhost}/conf/userdir.conf":
    ensure  => $ensure,
    source  => 'puppet:///modules/apache/userdir.conf',
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }
}
