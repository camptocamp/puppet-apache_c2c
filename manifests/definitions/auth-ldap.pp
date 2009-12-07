define apache::auth::ldap ($ensure="present", $authname="Private Area", $vhost, $ldapUrl, $location) {

  $fname = regsubst($name, "\s", "_", "G")

  case $operatingsystem {
    redhat,CentOS : { $wwwroot = "/var/www/vhosts" }
    debian : { $wwwroot = "/var/www" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  if defined(Apache::Module["ldap"]) {} else {
    apache::module {"ldap": }
  }

  if defined(Apache::Module["authnz_ldap"]) {} else {
    apache::module {"authnz_ldap": }
  }

  file {"${wwwroot}/${vhost}/conf/${fname}.conf":
    ensure  => $ensure,
    content => template("apache/auth-ldap.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
  }

}
