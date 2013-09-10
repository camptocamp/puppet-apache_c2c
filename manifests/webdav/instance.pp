define apache::webdav::instance ($ensure=present, $vhost, $directory=false,$mode=2755) {

  $wwwroot = $apache::root
  validate_absolute_path($wwwroot)

  if $directory {
    $davdir = "${directory}/webdav-${name}"
  } else {
    $davdir = "${wwwroot}/${vhost}/private/webdav-${name}"
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
  file { "${wwwroot}/${vhost}/conf/webdav-${name}.conf":
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
