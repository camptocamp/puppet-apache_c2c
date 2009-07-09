define apache::auth::basic::file::user (
  $ensure="present", 
  $authname="Private Area",
  $vhost,
  $location="/",
  $authUserFile=false,
  $users="valid-user"){
 
  if defined(Apache::Module["authn_file"]) {} else {
    apache::module {"authn_file": }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "/var/www/${vhost}/private/htpasswd"
  }

  if $users != "valid-user" {
    $_users = "user $users"
  } else {
    $_users = $users
  }

  file {"/var/www/${vhost}/conf/auth-basic-file-user-${name}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-user.erb"),
    notify => Exec["apache-graceful"],
  }

}
