define apache::auth::basic::file::group (
  $ensure="present", 
  $authname="Private Area",
  $vhost,
  $location="/",
  $authUserFile=false,
  $authGroupFile=false,
  $groups){

  $fname = regsubst($name, "\s", "_", "G")

  include apache::params
 
  if defined(Apache::Module["authn_file"]) {} else {
    apache::module {"authn_file": }
  }

  if $authUserFile {
    $_authUserFile = $authUserFile
  } else {
    $_authUserFile = "${apache::params::root}/${vhost}/private/htpasswd"
  }

  if $authGroupFile {
    $_authGroupFile = $authGroupFile
  } else {
    $_authGroupFile = "${apache::params::root}/${vhost}/private/htgroup"
  }

  file { "${apache::params::root}/${vhost}/conf/auth-basic-file-group-${fname}.conf":
    ensure => $ensure,
    content => template("apache/auth-basic-file-group.erb"),
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }

}
