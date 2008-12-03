define apache::redirectmatch ($ensure, $vhost, $regex, $url) {
  file {"/var/www/${vhost}/conf/redirect-${name}.conf":
    ensure  => $ensure,
    content => "RedirectMatch ${regex} ${url}\n",
    notify  => Service["apache2"],
  }
}
