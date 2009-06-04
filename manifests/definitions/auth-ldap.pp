define apache::auth::ldap ($ensure="present", $authname="Private Area", $vhost, $ldapUrl, $location) {

  case $operatingsystem {
    redhat : { $wwwroot = "/var/www/vhosts" }
    debian : { $wwwroot = "/var/www" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  if defined(Apache::Module["ldap"]) {} else {
    apache::module {"ldap": }
  }

  if defined(Apache::Module["authnz_ldap"]) {} else {
    apache::module {"authnz_ldap": }
  }

  file {"${wwwroot}/${vhost}/conf/${name}.conf":
    ensure  => $ensure,
    content => template("apache/auth-ldap.erb"),
    notify  => Service["apache"],
  }

}
