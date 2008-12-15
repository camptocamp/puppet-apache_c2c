define apache::proxypass(
  $ensure,
  $location,
  $url,
  $vhost
) {
  file{"${wwwroot}/${vhost}/conf/proxypass-${name}.conf":
    ensure => $ensure,
    content => template("apache/proxypass.erb"),
    notify  => Service["${wwwpkgname}"],
  }
}
