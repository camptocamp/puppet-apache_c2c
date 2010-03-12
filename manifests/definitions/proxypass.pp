/*

== Definition: apache::proxypass

Simple way of defining a proxypass directive for a given virtualhost.

This definition will ensure all the required modules are loaded and will
drop a configuration snippet in the virtualhost's conf/ directory.

Parameters:
- *ensure*: present/absent.
- *location*: path in virtualhost's context to pass through using the ProxyPass
  directive.
- *url*: destination to which the ProxyPass directive points to.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache::proxypass { "proxy legacy dir to legacy server":
    ensure   => present,
    location => "/legacy/",
    url      => "http://legacyserver.example.com",
    vhost    => "www.example.com",
  }

*/
define apache::proxypass ($ensure="present", $location="", $url="", $vhost) {

  $fname = regsubst($name, "\s", "_", "G")

  if defined(Apache::Module["proxy"]) {} else {
    apache::module {"proxy": }
  }

  if defined(Apache::Module["proxy_http"]) {} else {
    apache::module {"proxy_http": }
  }

  case $operatingsystem {
    redhat,CentOS : {
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  file{"${wwwroot}/${vhost}/conf/proxypass-${fname}.conf":
    ensure => $ensure,
    content => template("apache/proxypass.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
    require => Apache::Vhost[$vhost],
  }
}
