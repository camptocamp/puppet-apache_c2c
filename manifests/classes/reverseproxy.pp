class apache::reverseproxy {

  apache::module {["proxy", "proxy_http", "proxy_ajp", "proxy_connect"]: }

  file { "reverseproxy.conf":
    ensure => "present",
    path => $operatingsystem ? {
      RedHat => "/etc/httpd/conf.d/reverseproxy.conf",
      CentOS => "/etc/httpd/conf.d/reverseproxy.conf",
      Debian => "/etc/apache2/conf.d/reverseproxy.conf",
    },
    content => "# file managed by puppet
<IfModule mod_proxy.c>
  ProxyRequests Off
  <Proxy *>
    Order Deny,Allow
    Deny from all
  </Proxy>
</IfModule>
",
    notify  => Exec["apache-graceful"],
    require => Package["apache"],
  }

}
