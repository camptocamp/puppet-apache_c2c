class apache::localproxy {

  # The purpose of this cgi script is to be able to test name-based
  # virtualhosted websites before changing DNS entries.
  #
  # An alternative is to add a line in /etc/hosts on the client side.

  $nph_http_proxy = "${fqdn}:80"


  $filepath = $operatingsystem ? {
    RedHat => "/var/www/cgi-bin/nph-proxy.cgi",
    CentOS => "/var/www/cgi-bin/nph-proxy.cgi",
    Debian => "/usr/lib/cgi-bin/nph-proxy.cgi",
  }
  
  file { "cgi-bin/nph-proxy.cgi":
    path => $filepath,
    mode => "0755",
    owner => "root",
    content => template("apache/nph-proxy.cgi.erb"),
    require => Package["apache"],
  }

  file { "conf.d/localproxy.conf":
    path => $operatingsystem ? {
      RedHat => "/etc/httpd/conf.d/zzz-localproxy.conf",
      CentOS => "/etc/httpd/conf.d/zzz-localproxy.conf",
      Debian => "/etc/apache2/conf.d/zzz-localproxy.conf",
    },
    content => "# file managed by puppet
# NOTE: this file must be parsed by apache AFTER modsecurity rule definitions !
SecRuleRemoveByMsg \"Proxy access attempt\"\n",
    require => Package["apache"],
    notify => Exec["apache-graceful"],
  }
}
