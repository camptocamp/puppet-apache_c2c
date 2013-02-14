/*

== Definition: apache::balancer

Define a basic balanced proxy, to split requests between different backends,
with an optional hot standby server.

This definition will ensure all the required modules are loaded and will
drop a configuration snippet in the virtualhost's conf/ directory.

Parameters:
- *ensure*: present/absent.
- *location*: path to balance between backends.
- *proto*: protocol used to communicate with the backends. "http" or "ajp" are
  the usual suspects. "http" is the default.
- *members*: array of "hostname:port" pairs for each registered backend.
- *standbyurl*: optional URL of the sorryserver (requests will get directed to
  this address when all backends are dead).
- *params*: array of parameters to pass to every backend.
  See: http://httpd.apache.org/docs/2.2/mod/mod_proxy.html#proxypass
  Defaults to "retry=5"
- *vhost*: the virtualhost to which this directive will apply. Mandatory
  parameter.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache::balancer { "my balanced service":
    location   => "/mywebapp/",
    proto      => "ajp",
    members    => [
      "node1.cluster:8009",
      "node2.cluster:8009",
      "node3.cluster:8009"
    ],
    params     => ["retry=20", "min=3", "flushpackets=auto"],
    standbyurl => "http://sorryserver.cluster/",
    vhost      => "www.example.com",
  }

*/
define apache::balancer (
  $vhost,
  $ensure='present',
  $location='',
  $proto='http',
  $members=[],
  $standbyurl='',
  $params=['retry=5'],
  $filename=''
) {

  # normalise name
  $fname = regsubst($name, '\s', '_', 'G')

  include apache::params

  $balancer = "balancer://${fname}"

  if !defined(Apache::Module['proxy']) {
    apache::module {'proxy':
      ensure => $ensure,
    }
  }

  if !defined(Apache::Module['proxy_balancer']) {
    apache::module {'proxy_balancer':
      ensure => $ensure,
    }
  }

  # ensure proxy modules are enabled
  case $proto {
    http: {
      if !defined(Apache::Module['proxy_http']) {
        apache::module {'proxy_http':
          ensure => $ensure,
        }
      }
    }

    ajp: {
      if !defined(Apache::Module['proxy_ajp']) {
        apache::module {'proxy_ajp':
          ensure => $ensure,
        }
      }
    }

    default: {
      fail ("Unknown proto '${proto}'")
    }
  }

  file{"${name} balancer on ${vhost}":
    ensure  => $ensure,
    content => template('apache/balancer.erb'),
    seltype => $::operatingsystem ? {
      'RedHat' => 'httpd_config_t',
      'CentOS' => 'httpd_config_t',
      default  => undef,
    },
    path    => $filename ? {
      ''      => "${apache::params::root}/${vhost}/conf/balancer-${fname}.conf",
      default => "${apache::params::root}/${vhost}/conf/${filename}",
    },
    notify  => Exec['apache-graceful'],
    require => Apache::Vhost[$vhost],
  }
}
