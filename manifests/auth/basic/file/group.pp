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
    $authUserFile_real = $authUserFile
  } else {
    $authUserFile_real = "${apache::params::root}/${vhost}/private/htpasswd"
  }

  if $authGroupFile {
    $authGroupFile_real = $authGroupFile
  } else {
    $authGroupFile_real = "${apache::params::root}/${vhost}/private/htgroup"
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
