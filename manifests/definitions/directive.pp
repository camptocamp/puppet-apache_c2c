/*

== Definition: apache::directive

Convenient wrapper around File[] resources to add random configuration
snippets to an apache virtualhost.

Parameters:
- *ensure*: present/absent.
- *directive*: apache directive(s) to be applied in the corresponding
  <VirtualHost> section.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache::directive { "example 1":
    ensure    => present,
    directive => "
      RewriteEngine on
      RewriteRule ^/?$ https://www.example.com/
    ",
    vhost     => "www.example.com",
  }

  apache::directive { "example 2":
    ensure    => present,
    directive => content("example/snippet.erb"),
    vhost     => "www.example.com",
  }

*/
define apache::directive ($ensure="present", $directive="", $vhost) {

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

  file{"${wwwroot}/${vhost}/conf/directive-${fname}.conf":
    ensure => $ensure,
    content => "# file managed by puppet\n${directive}\n",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify  => Service["${wwwpkgname}"],
    require => Apache::Vhost[$vhost],
  }
}
