define apache::userdirinstance ($ensure=present, $vhost) {

  $wwwroot = $apache::root
  validate_absolute_path($wwwroot)

  file { "${wwwroot}/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    source => "puppet:///modules/${module_name}/userdir.conf",
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }
}
