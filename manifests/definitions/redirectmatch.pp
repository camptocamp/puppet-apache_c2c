/*

== Definition: apache::redirectmatch

Convenient way to declare a RedirectMatch directive in a virtualhost context.

Parameters:
- *ensure*: present/absent.
- *regex*: regular expression matching the part of the URL which should get
  redirected. Mandatory.
- *url*: destination URL the redirection should point to. Mandatory.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.

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
define apache::redirectmatch ($ensure="present", $regex, $url, $vhost) {

  $fname = regsubst($name, "\s", "_", "G")

  case $operatingsystem {
    redhat,CentOS : {
      $wwwpkgname = "httpd"
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwpkgname = "apache2"
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  file { "${wwwroot}/${vhost}/conf/redirect-${fname}.conf":
    ensure  => $ensure,
    content => "# file managed by puppet\nRedirectMatch ${regex} ${url}\n",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Exec["apache-graceful"],
    require => Apache::Vhost[$vhost],
  }
}
