define apache::directive ($ensure="present", $directive="", $vhost) {

  $fname = regsubst($name, "\s", "_", "G")

  case $operatingsystem {
    redhat,CentOS : {
      $wwwpkgname = "httpd"
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwpkgname = "apache2"
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  file{"${wwwroot}/${vhost}/conf/directive-${fname}.conf":
    ensure => $ensure,
    content => "# file managed by puppet\n${directive}\n",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Service["${wwwpkgname}"],
    require => Apache::Vhost[$vhost],
  }
}
