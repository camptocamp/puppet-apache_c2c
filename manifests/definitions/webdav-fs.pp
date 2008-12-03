define apache::webdav::fs ($ensure, $vhost, $davDir, $confname) {

  $location = $name

  file {"/var/www/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/webdav-fs.erb"),
    notify  => Service["apache2"],
    require => [File["$davDir"]],
  }

  file {"$davDir":
    ensure  => directory,
    owner   => www-data,
    group   => www-data,
  }

}
