class apache::deflate {

  apache::module {"deflate":
    ensure => present,
  }

  #TODO: remove soon
  file { ["/etc/apache2/conf.d/deflate-javascript.conf",
          "/etc/apache2/conf.d/deflate-css.conf"]:
    ensure  => absent,
    require => File["deflate.conf"],
  }

  file { "deflate.conf":
    ensure => present,
    path => $operatingsystem ? {
      RedHat => "/etc/httpd/conf.d/deflate.conf",
      Debian => "/etc/apache2/conf.d/deflate.conf",
    },
    content => "# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript text/css
  BrowserMatch Safari no-gzip
</IfModule>
",
    notify  => Service["apache"],
    require => Package["apache"],
  }

}
