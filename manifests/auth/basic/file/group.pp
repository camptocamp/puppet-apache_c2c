define apache_c2c::auth::basic::file::group(
  $vhost,
  $groups,
  $ensure        = 'present',
  $authname      = false,
  $location      = '/',
  $authUserFile  = false,
  $authGroupFile = false,
) {

  validate_string($groups)

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $fname = regsubst($name, '\s', '_', 'G')

  include apache_c2c::params

  if defined(Apache_c2c::Module['authn_file']) {} else {
    apache_c2c::module {'authn_file': }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${wwwroot}/${vhost}/private/htpasswd"
  }

  if $authGroupFile {
    $_authGroupFile = $authGroupFile
  } else {
    $_authGroupFile = "${wwwroot}/${vhost}/private/htgroup"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure  => $ensure,
    content => template("${module_name}/auth-basic-file-group.erb"),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
