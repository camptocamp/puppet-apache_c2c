define apache::aw-stats($ensure=present){
  file{"/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    content => template("apache/awstats.erb"),
    require => Package["apache2"],
  }

  file{"/var/www/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => "puppet:///apache/awstats.conf",
    notify  => Service["apache2"],
  }
}
