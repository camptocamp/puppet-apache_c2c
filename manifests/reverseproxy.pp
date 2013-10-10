class apache_c2c::reverseproxy {

  include apache_c2c::params

  apache_c2c::module {['proxy', 'proxy_http', 'proxy_ajp', 'proxy_connect']: }

  file { 'reverseproxy.conf':
    ensure  => 'present',
    path    => "${apache_c2c::params::conf}/conf.d/reverseproxy.conf",
    content => '# file managed by puppet
<IfModule mod_proxy.c>
  ProxyRequests Off
  <Proxy *>
    Order Deny,Allow
    Deny from all
  </Proxy>
</IfModule>
',
    notify  => Exec['apache-graceful'],
    require => Package['apache'],
  }

}
