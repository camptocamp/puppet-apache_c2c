define apache::proxypass ($ensure="present", $location, $url, $vhost) {

  $fname = regsubst($name, "\s", "_", "G")

  case $operatingsystem {
    redhat : {
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  file{"${wwwroot}/${vhost}/conf/proxypass-${fname}.conf":
    ensure => $ensure,
    content => template("apache/proxypass.erb"),
    notify  => Service["apache"],
    require => Apache::Vhost[$vhost],
  }
}
