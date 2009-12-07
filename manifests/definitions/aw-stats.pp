define apache::aw-stats($ensure=present) {

  case $operatingsystem {
    redhat,CentOS : {
      $wwwroot = "/var/www/vhosts"
      $conf = "awstats.rh.conf"
    }
    debian : {
      $wwwroot = "/var/www"
      $conf = "awstats.deb.conf"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  file{"/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    content => template("apache/awstats.erb"),
    require => [Package["apache"], Class["apache::awstats"]],
  }

  file{"${wwwroot}/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => "puppet:///apache/${conf}",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
    require => Apache::Vhost[$name],
  }
}
