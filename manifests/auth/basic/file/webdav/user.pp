define apache_c2c::auth::basic::file::webdav::user (
  $vhost,
  $ensure=present,
  $authname=false,
  $location="/${name}",
  $authUserFile=false,
  $rw_users='valid-user',
  $limits='GET HEAD OPTIONS PROPFIND',
  $ro_users='',
  $allow_anonymous=false,
  $restricted_access=[]) {

  validate_string($rw_users)
  validate_string($limits)
  validate_string($ro_users)
  validate_array($restricted_access)

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

  if $rw_users != 'valid-user' {
    $_users = "user ${rw_users}"
  } else {
    $_users = $rw_users
  }

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/auth-basic-file-webdav-${fname}.conf":
    ensure  => $ensure,
    content => template("${module_name}/auth-basic-file-webdav-user.erb"),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
