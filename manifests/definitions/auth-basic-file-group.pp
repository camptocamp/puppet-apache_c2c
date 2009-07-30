define apache::auth::basic::file::group (
  $ensure="present", 
  $authname="Private Area",
  $vhost,
  $location="/",
  $authUserFile=false,
  $authGroupFile=false,
  $groups){

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

  if $authGroupFile {
    $_authGroupFile = $authGroupFile
  } else {
    $_authGroupFile = "${wwwroot}/${vhost}/private/htgroup"
  }

  file {"${wwwroot}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-group.erb"),
    notify => Exec["apache-graceful"],
  }

}
