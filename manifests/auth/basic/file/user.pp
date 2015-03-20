define apache_c2c::auth::basic::file::user(
  $vhost,
  $ensure         = 'present',
  $authname       = false,
  $location       = '/',
  $auth_user_file = undef,
  $users          = 'valid-user',
) {

  validate_string($users)

  $fname = regsubst($name, '\s', '_', 'G')

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if !defined(Apache_c2c::Module['authn_file']) {
    apache_c2c::module {'authn_file': }
  }

  if $auth_user_file {
    $_auth_user_file = $auth_user_file
  } else {
    $_auth_user_file = "${wwwroot}/${vhost}/private/htpasswd"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  if $users != 'valid-user' {
    $_users = "user ${users}"
  } else {
    $_users = $users
  }

  $seltype = $::osfamily ? {
    'RedHat' => 'httpd_config_t',
    default  => undef,
  }
  file {"${wwwroot}/${vhost}/conf/auth-basic-file-user-${fname}.conf":
    ensure  => $ensure,
    content => template('apache_c2c/auth-basic-file-user.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
