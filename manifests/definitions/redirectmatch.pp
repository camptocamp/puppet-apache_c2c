define apache::redirectmatch ($ensure, $vhost, $regex, $url) {

  file {"/var/www/${vhost}/conf/redirect-${name}.conf":
    ensure  => $ensure,
    content => "RedirectMatch ${regex} ${url}\n",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
  }
}
