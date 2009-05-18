define apache::proxypass ($ensure="present", $location, $url, $vhost) {

  case $operatingsystem {
    redhat : {
      $wwwpkgname = "httpd"
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwpkgname = "apache2"
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  file{"${wwwroot}/${vhost}/conf/proxypass-${name}.conf":
    ensure => $ensure,
    content => template("apache/proxypass.erb"),
    notify  => Service["${wwwpkgname}"],
    require => Apache::Vhost[$vhost],
  }
}
