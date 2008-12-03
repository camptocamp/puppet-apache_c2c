define apache::auth::ldap ($ensure, $vhost, $ldapUrl, $confname) {

  $location = $name

  file {"/var/www/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/auth-ldap.erb"),
    notify  => Service["apache2"],
  }

}
