define apache::auth::access ($ensure, $vhost, $authname="Private Area", $confname, $replace=true) {

  $location = $name

  file {"/var/www/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/auth-access.erb"),
    notify  => Service["apache2"],
    replace => $replace,
  }

}
