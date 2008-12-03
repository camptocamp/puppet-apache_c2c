define apache::auth::file ($ensure, $vhost, $userFile, $confname) {

  $location = $name

  file {"/var/www/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/auth-file.erb"),
    notify  => Service["apache2"],
  }

}
