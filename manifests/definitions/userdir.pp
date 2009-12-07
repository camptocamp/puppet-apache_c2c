define apache::userdirinstance ($ensure=present, $vhost) {

  file {"/var/www/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    source => 'puppet:///apache/userdir.conf',
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    require => File["/var/www/${vhost}/conf"],
    notify => Exec["apache-graceful"],
  }
}
