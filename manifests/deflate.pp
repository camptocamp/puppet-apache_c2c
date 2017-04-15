class apache_c2c::deflate {

  include ::apache_c2c::params

  apache_c2c::module {'deflate':
    ensure => present,
  }

  if $::apache_c2c::backend != 'puppetlabs' {
    file { 'deflate.conf':
      ensure  => file,
      path    => "${apache_c2c::params::conf}/conf.d/deflate.conf",
      content => '# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript application/json text/css text/html text/plain text/xml
  BrowserMatch Safari/4 no-gzip
</IfModule>
',
      notify  => Exec['apache-graceful'],
      require => Package['httpd'],
    }
  }

}
