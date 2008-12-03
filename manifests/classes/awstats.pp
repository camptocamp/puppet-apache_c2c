class apache::awstats {

  package{"awstats":
    ensure => installed
  }

  file {"/etc/awstats/awstats.conf":
    ensure  => absent,
    require => Package[awstats]
  }

  file {"/etc/awstats/awstats.conf.local":
    ensure  => absent,
    require => Package[awstats]
  }

  cron {"update all awstats virtual hosts":
    command => "/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null",
    user    => "root",
    minute  => [0,10,20,30,40,50],
    require => Package[awstats]
  }
  file{"/etc/cron.d/awstats":
    ensure => absent,
  }


}
