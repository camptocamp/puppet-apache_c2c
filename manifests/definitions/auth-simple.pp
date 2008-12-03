define apache::auth::simple ($ensure, $vhost, $location="/", $username, $password) {

  apache::auth::basic {"simple":
    ensure   => $ensure,
    vhost    => $vhost,
    location => $location,
    authname => "Restricted Access",
    userfile => "/var/www/${vhost}/private/htpasswd",
  }

  file {"/var/www/${vhost}/private/htpasswd":
    ensure  => $ensure,
    content => "${username}:${password}\n",
  }

}
