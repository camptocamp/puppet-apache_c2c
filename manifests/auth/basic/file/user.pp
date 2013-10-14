define apache_c2c::auth::basic::file::user(
  $vhost,
  $ensure       = 'present',
  $authname     = false,
  $location     = '/',
  $authUserFile = false,
  $users        = 'valid-user',
) {

  validate_string($users)

  $fname = regsubst($name, '\s', '_', 'G')

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if !defined(Apache_c2c::Module['authn_file']) {
    apache_c2c::module {'authn_file': }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${wwwroot}/${vhost}/private/htpasswd"
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

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file {"${wwwroot}/${vhost}/conf/auth-basic-file-user-${fname}.conf":
    ensure  => $ensure,
    content => template("${module_name}/auth-basic-file-user.erb"),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
