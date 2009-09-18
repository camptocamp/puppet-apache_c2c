define apache::webdav::instance ($ensure=present, $vhost, $directory=false) {

  case $operatingsystem {
    redhat : { $wwwroot = "/var/www/vhosts" }
    debian : { $wwwroot = "/var/www" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
 
  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${wwwroot}/${vhost}/private/webdav-${name}" 
  }

  file {$davdir:
    ensure => directory,
    owner => "www-data",
    group => "www-data",
    mode => 2755,
  }

  # configuration
  file {"${wwwroot}/${vhost}/conf/webdav-${name}.conf" :
    ensure => $ensure,
    content => template("apache/webdav-config.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      default  => undef,
    },
    require => File[$davdir],
    notify => Exec["apache-graceful"],
  }

}
