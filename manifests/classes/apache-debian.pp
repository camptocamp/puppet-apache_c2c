class apache::debian inherits apache::base {

  package {"apache2":
    ensure => installed,
    alias  => "apache"
  }

  service {"apache2":
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package["apache"],
    alias => "apache"
  }

  user {"www-data":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache user",
  }

  group {"www-data":
    ensure  => present,
    require => Package["apache"],
    alias   => "apache group",
  }

  package {["apache2-mpm-prefork", "libapache2-mod-proxy-html"]:
    ensure  => installed,
    require => Package["apache"],
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
    notify  => Service["apache"],
    require => Package["apache"],
  }

}
