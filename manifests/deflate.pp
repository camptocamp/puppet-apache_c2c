class apache::deflate {

  include apache::params

  apache::module {"deflate":
    ensure => present,
  }

  file { "deflate.conf":
    ensure => present,
    path => "${apache::params::conf}/conf.d/deflate.conf",
    content => "# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript application/json text/css text/html text/plain text/xml
  BrowserMatch Safari/4 no-gzip
</IfModule>
",
    notify  => Exec["apache-graceful"],
    require => Package["apache"],
  }

}
