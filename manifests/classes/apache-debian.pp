class apache::debian {

  package {"apache2":
    ensure => installed,
  }

  service {"apache2":
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package["apache2"],
  }

  user {"www-data":
    ensure  => present,
    require => Package["apache2"],
    alias   => "apache2 user",
  }

  group {"www-data":
    ensure  => present,
    require => Package["apache2"],
    alias   => "apache2 group",
  }

  package {["apache2-mpm-prefork", "libapache2-mod-proxy-html"]:
    ensure  => installed,
    require => Package["apache2"],
  }
  
  # directory not present in lenny
  file {"/var/www/apache2-default":
    ensure  => absent,
    force => true,
  }

  file {"/var/www/index.html":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => 644,
    content => "<html><body><h1>It works!</h1></body></html>\n",
    require => File["/var/www"],
  }

  file { "/etc/apache2/ports.conf":
    content => "ServerName 127.0.1.1\nListen 80\n",
    notify  => Service["apache2"],
    require => Package["apache2"],
  }

}
