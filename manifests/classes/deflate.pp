class apache::deflate {

  apache::module {"deflate":
    ensure => present,
  }

  file { "deflate.conf":
    ensure => present,
    path => $operatingsystem ? {
      RedHat => "/etc/httpd/conf.d/deflate.conf",
      CentOS => "/etc/httpd/conf.d/deflate.conf",
      Debian => "/etc/apache2/conf.d/deflate.conf",
    },
    content => "# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript text/css
  BrowserMatch Safari no-gzip
</IfModule>
",
    notify  => Exec["apache-graceful"],
    require => Package["apache"],
  }

}
