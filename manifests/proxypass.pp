# == Definition: apache::proxypass
#
# Simple way of defining a proxypass directive for a given virtualhost.
#
# This definition will ensure all the required modules are loaded and will
# drop a configuration snippet in the virtualhost's conf/ directory.
#
# Parameters:
# - *ensure*: present/absent.
# - *location*: path in virtualhost's context to pass through using the
#   ProxyPass directive.
# - *url*: destination to which the ProxyPass directive points to.
# - *params*: a table of key=value (min, max, timeout, retry, etc.) described
#   in the ProxyPass Directive documentation
#   http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass
# - *vhost*: the virtualhost to which this directive will apply. Mandatory.
# - *filename*: basename of the file in which the directive(s) will be put.
#   Useful in the case directive order matters: apache reads the files in conf/
#   in alphabetical order.
#
# Requires:
# - Class["apache"]
# - matching Apache_c2c::Vhost[] instance
#
# Example usage:
#
#   apache_c2c::proxypass { "proxy legacy dir to legacy server":
#     ensure   => present,
#     location => "/legacy/",
#     url      => "http://legacyserver.example.com",
#     params   => ["retry=5", "ttl=120"],
#     vhost    => "www.example.com",
#   }
#
define apache_c2c::proxypass (
  $vhost,
  $ensure='present',
  $location='',
  $url='',
  $params=[],
  $filename=''
) {

  $fname = regsubst($name, '\s', '_', 'G')

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if defined(Apache_c2c::Module['proxy']) {} else {
    apache_c2c::module {'proxy':
    }
  }

  if defined(Apache_c2c::Module['proxy_http']) {} else {
    apache_c2c::module {'proxy_http':
    }
  }

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  $path = $filename ? {
    ''      => "${wwwroot}/${vhost}/conf/proxypass-${fname}.conf",
    default => "${wwwroot}/${vhost}/conf/${filename}",
  }
  file { "${name} proxypass on ${vhost}":
    ensure  => $ensure,
    content => template("${module_name}/proxypass.erb"),
    seltype => $seltype,
    path    => $path,
    notify  => Exec['apache-graceful'],
    require => Apache_c2c::Vhost[$vhost],
  }
}
