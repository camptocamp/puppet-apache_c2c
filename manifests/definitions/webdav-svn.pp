define apache::webdav::svn ($ensure, $vhost, $parentPath, $confname) {

  $location = $name

  file {"/var/www/${vhost}/conf/${confname}.conf":
    ensure  => $ensure,
    content => template("apache/webdav-svn.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
  }

}
