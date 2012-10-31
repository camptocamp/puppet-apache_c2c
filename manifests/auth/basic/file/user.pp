define apache::auth::basic::file::user (
  $ensure="present",
  $authname=false,
  $vhost,
  $location="/",
  $authUserFile=false,
  $users="valid-user"){

  $fname = regsubst($name, "\s", "_", "G")

  include apache::params

  if !defined(Apache::Module["authn_file"]) {
    apache::module {"authn_file": }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${apache::params::root}/${vhost}/private/htpasswd"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  if $users != "valid-user" {
    $_users = "user $users"
  } else {
    $_users = $users
  }

  file {"${apache::params::root}/${vhost}/conf/auth-basic-file-user-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-user.erb"),
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
