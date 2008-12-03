define apache::auth::basic ($ensure, $authname, $vhost, $location, $userfile, $users="valid-user") {

  file {"/var/www/${vhost}/conf/auth-${name}.conf":
    ensure  => $ensure,
    content => template("apache/auth-simple.conf.erb"),
    notify  => Service["apache2"],
  }

}
