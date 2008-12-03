class apache::deflate {
  apache::module {"deflate":
    ensure => present,
  }

  file {"/etc/apache2/conf.d/deflate-javascript.conf":
    ensure  => present,
    content => "<IfModule mod_deflate.c>\nAddOutputFilterByType DEFLATE application/x-javascript\nBrowserMatch Safari no-gzip</IfModule>\n",
    notify  => Service["apache2"],
    require => Package["apache2"],
  }

  file {"/etc/apache2/conf.d/deflate-css.conf":
    ensure  => present,
    content => "<IfModule mod_deflate.c>\nAddOutputFilterByType DEFLATE text/css\n</IfModule>\n",
    notify  => Service["apache2"],
    require => Package["apache2"],
  }
}
