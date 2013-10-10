# == Definition: apache::redirectmatch
#
# Convenient way to declare a RedirectMatch directive in a virtualhost context.
#
# Parameters:
# - *ensure*: present/absent.
# - *regex*: regular expression matching the part of the URL which should get
#   redirected. Mandatory.
# - *url*: destination URL the redirection should point to. Mandatory.
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
#   apache_c2c::redirectmatch { "example":
#     regex => "^/(foo|bar)",
#     url   => "http://foobar.example.com/",
#     vhost => "www.example.com",
#   }
#
define apache_c2c::redirectmatch (
  $regex,
  $url,
  $vhost,
  $ensure='present',
  $filename=''
) {

  $fname = regsubst($name, '\s', '_', 'G')

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  $path = $filename ? {
    ''      => "${wwwroot}/${vhost}/conf/redirect-${fname}.conf",
    default => "${wwwroot}/${vhost}/conf/${filename}",
  }
  file { "${name} redirect on ${vhost}":
    ensure  => $ensure,
    content => "# file managed by puppet\nRedirectMatch ${regex} ${url}\n",
    seltype => $seltype,
    path    => $path,
    notify  => Exec['apache-graceful'],
    require => Apache_c2c::Vhost[$vhost],
  }
}
