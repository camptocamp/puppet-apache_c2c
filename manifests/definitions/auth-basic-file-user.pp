define apache::auth::basic::file::user (
  $ensure="present", 
  $authname="Private Area",
  $vhost,
  $location="/",
  $authUserFile=false,
  $users="valid-user"){

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
    $_users = "user $users"
  } else {
    $_users = $users
  }

  file {"${wwwroot}/${vhost}/conf/auth-basic-file-user-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-user.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
