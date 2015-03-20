define apache_c2c::auth::basic::ldap(
  $vhost,
  $auth_ldap_url,
  $ensure                          = 'present',
  $authname                        = false,
  $location                        = '/',
  $auth_ldap_bind_dn               = false,
  $auth_ldap_bind_password         = false,
  $auth_ldap_charset_config        = false,
  $auth_ldap_compare_dn_on_server  = false,
  $auth_ldap_dereference_aliases   = false,
  $auth_ldap_group_attribute       = false,
  $auth_ldap_group_attribute_is_dn = false,
  $auth_ldap_remote_user_attribute = false,
  $auth_ldap_remote_user_is_dn     = false,
  $auth_ldap_authoritative         = false,
  $authz_require                   = 'valid-user',
) {

  $fname = regsubst($name, '\s', '_', 'G')

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if defined(Apache_c2c::Module['ldap']) {} else {
    apache_c2c::module {'ldap': }
  }

  if defined(Apache_c2c::Module['authnz_ldap']) {} else {
    apache_c2c::module {'authnz_ldap': }
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  $seltype = $::osfamily ? {
    'RedHat' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/auth-basic-ldap-${fname}.conf":
    ensure  => $ensure,
    content => template('apache_c2c/auth-basic-ldap.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
