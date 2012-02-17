define apache::userdirinstance ($ensure=present, $vhost) {

  include apache::params

  file { "${apache::params::root}/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    source => 'puppet:///modules/apache/userdir.conf',
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }
}
