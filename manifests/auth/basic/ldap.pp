define apache::auth::basic::ldap (
  $ensure="present",
  $authname=false,
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

  include apache::params

  if defined(Apache::Module["ldap"]) {} else {
    apache::module {"ldap": }
  }

  if defined(Apache::Module["authnz_ldap"]) {} else {
    apache::module {"authnz_ldap": }
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  file { "${apache::params::root}/${vhost}/conf/auth-basic-ldap-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-ldap.erb"),
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
