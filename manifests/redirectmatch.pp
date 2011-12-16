/*

== Definition: apache::redirectmatch

Convenient way to declare a RedirectMatch directive in a virtualhost context.

Parameters:
- *ensure*: present/absent.
- *regex*: regular expression matching the part of the URL which should get
  redirected. Mandatory.
- *url*: destination URL the redirection should point to. Mandatory.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache::redirectmatch { "example":
    regex => "^/(foo|bar)",
    url   => "http://foobar.example.com/",
    vhost => "www.example.com",
  }

*/
define apache::redirectmatch ($ensure="present", $regex, $url, $filename="", $vhost) {

  $fname = regsubst($name, "\s", "_", "G")

  include apache::params

  file { "${name} redirect on ${vhost}":
    ensure  => $ensure,
    content => "# file managed by puppet\nRedirectMatch ${regex} ${url}\n",
    seltype => $::operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    name    => $filename ? {
      ""      => "${apache::params::root}/${vhost}/conf/redirect-${fname}.conf",
      default => "${apache::params::root}/${vhost}/conf/${filename}",
    },
    notify  => Exec["apache-graceful"],
    require => Apache::Vhost[$vhost],
  }
}
