define apache::proxypass ($ensure, $location, $url, $vhost) {

  case $operatingsystem {
    redhat: { $wwwpkgname = "httpd" }
    debian: { $wwwpkgname = "apache2" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }    

  file{"${wwwroot}/${vhost}/conf/proxypass-${name}.conf":
    ensure => $ensure,
    content => template("apache/proxypass.erb"),
    notify  => Service["${wwwpkgname}"],
  }
}
