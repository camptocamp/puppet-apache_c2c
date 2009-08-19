define apache::auth::basic::file::webdav::user (
  $ensure=present,
  $authname="Private Area",
  $vhost,
  $location="/",
  $authUserFile=false,
  $rw_users="valid-user",
  $limits='GET HEAD OPTIONS PROPFIND',
  $ro_users=False) {

  $fname = regsubst($name, "\s", "_", "G")

  case $operatingsystem {
    redhat : { $wwwroot = "/var/www/vhosts" }
    debian : { $wwwroot = "/var/www" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }
  
  if defined(Apache::Module["authn_file"]) {} else {
    apache::module {"authn_file": }
  }
  
  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${wwwroot}/${vhost}/private/htpasswd"
  }
  
  if $users != "valid-user" {
    $_users = "user $rw_users"
  } else {
    $_users = $users
  }
  
  file {"${wwwroot}/${vhost}/conf/auth-basic-file-webdav-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-webdav-user.erb"),
    notify => Exec["apache-graceful"],
  }

}
