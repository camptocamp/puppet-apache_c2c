define apache::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  $location = $name

  file {"/var/www/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/webdav-svn.erb"),
    notify  => Service["apache2"],
  }

}
