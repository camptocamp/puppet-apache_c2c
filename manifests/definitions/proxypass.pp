define apache::proxypass(
  $ensure,
  $location,
  $url,
  $vhost
) {
  file{"/var/www/${vhost}/conf/proxypass-${name}.conf":
    ensure => $ensure,
    content => template("apache/proxypass.erb"),
    notify  => Service["apache2"],
  }
}
