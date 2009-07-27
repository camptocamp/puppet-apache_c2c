define apache::aw-stats($ensure=present) {

  case $operatingsystem {
    redhat : {
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
    notify  => Exec["apache-graceful"],
    require => File["${wwwroot}/${name}/conf"],
  }
}
