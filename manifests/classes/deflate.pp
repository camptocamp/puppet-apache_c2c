class apache::deflate {
  apache::module {"deflate":
    ensure => present,
  }

  file {"/etc/apache2/conf.d/deflate-javascript.conf":
    ensure  => present,
    content => "<IfModule mod_deflate.c>\nAddOutputFilterByType DEFLATE application/x-javascript\nBrowserMatch Safari no-gzip</IfModule>\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

  file {"/etc/apache2/conf.d/deflate-css.conf":
    ensure  => present,
    content => "<IfModule mod_deflate.c>\nAddOutputFilterByType DEFLATE text/css\n</IfModule>\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }
}
