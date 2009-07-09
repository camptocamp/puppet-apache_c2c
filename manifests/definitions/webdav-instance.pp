define apache::webdav::instance ($ensure=present, $vhost, $directory=false) {

  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "/var/www/${vhost}/private/webdav-${name}" 
  }

  file {$davdir:
    ensure => directory,
    owner => "www-data",
    group => "www-data",
    mode => 2755,
  }

  # configuration
  file {"/var/www/${vhost}/conf/webdav-${name}.conf" :
    ensure => $ensure,
    content => template("apache/webdav-config.erb"),
    require => File[$davdir],
  }

}
