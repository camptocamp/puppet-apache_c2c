define apache::auth::group ($ensure, $authname, $vhost, $location, $userfile, $groupfile, $groupname) {

  file {"/var/www/${vhost}/conf/auth-${name}.conf":
    ensure  => $ensure,
    content => template("apache/auth-group.conf.erb"),
    notify  => Service["apache2"],
  }

}
