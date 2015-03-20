define apache_c2c::auth::basic::file::group(
  $vhost,
  $groups,
  $ensure          = 'present',
  $authname        = false,
  $location        = '/',
  $auth_user_file  = undef,
  $auth_group_file = undef,
) {

  validate_string($groups)

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $fname = regsubst($name, '\s', '_', 'G')

  include ::apache_c2c::params

  if defined(Apache_c2c::Module['authn_file']) {} else {
    apache_c2c::module {'authn_file': }
  }

  if $auth_user_file {
    $_auth_user_file = $auth_user_file
  } else {
    $_auth_user_file = "${wwwroot}/${vhost}/private/htpasswd"
  }

  if $auth_group_file {
    $_auth_group_file = $auth_group_file
  } else {
    $_auth_group_file = "${wwwroot}/${vhost}/private/htgroup"
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
  file { "${wwwroot}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure  => $ensure,
    content => template('apache_c2c/auth-basic-file-group.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
