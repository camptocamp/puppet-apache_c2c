define apache::webdav::instance ($ensure=present, $vhost, $directory=false) {

  include apache::params
 
  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${apache::params::root}/${vhost}/private/webdav-${name}"
  }

  file {$davdir:
    ensure => directory,
    owner => "www-data",
    group => "www-data",
    mode => 2755,
  }

  # configuration
  file { "${apache::params::root}/${vhost}/conf/webdav-${name}.conf":
    ensure => $ensure,
    content => template("apache/webdav-config.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    require => File[$davdir],
    notify => Exec["apache-graceful"],
  }

}
