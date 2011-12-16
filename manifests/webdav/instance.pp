define apache::webdav::instance ($ensure=present, $vhost, $directory=false,$mode=2755) {

  include apache::params
 
  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${apache::params::root}/${vhost}/private/webdav-${name}"
  }

  file {$davdir:
    ensure => $ensure ? {
      present => directory,
      absent  => absent,
    },
    owner => "www-data",
    group => "www-data",
    mode => $mode,
  }

  # configuration
  file { "${apache::params::root}/${vhost}/conf/webdav-${name}.conf":
    ensure => $ensure,
    content => template("apache/webdav-config.erb"),
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    require => File[$davdir],
    notify => Exec["apache-graceful"],
  }

}
