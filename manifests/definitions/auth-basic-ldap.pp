define apache::auth::basic::ldap (
  $ensure="present", 
  $authname="Private Area",
  $vhost,
  $location="/",
  $authLDAPUrl,
  $authLDAPBindDN=false,
  $authLDAPBindPassword=false,
  $authLDAPCharsetConfig=false,
  $authLDAPCompareDNOnServer=false,
  $authLDAPDereferenceAliases=false,
  $authLDAPGroupAttribute=false,
  $authLDAPGroupAttributeIsDN=false,
  $authLDAPRemoteUserAttribute=false,
  $authLDAPRemoteUserIsDN=false,
  $authzLDAPAuthoritative=false,
  $authzRequire="valid-user"){

  $fname = regsubst($name, "\s", "_", "G")

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

  file {"${wwwroot}/${vhost}/conf/auth-basic-ldap-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-ldap.erb"),
    notify => Exec["apache-graceful"],
  }

}
