class apache::params {

  $pkg = $operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
  }

  $root = $operatingsystem ? {
    /RedHat|CentOS/ => '/var/www/vhosts',
    /Debian|Ubuntu/ => '/var/www',
  }

  $user = $operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
  }

  $conf = $operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
  }

  $cgi = $operatingsystem ? {
    /RedHat|CentOS/ => '/var/www/cgi-bin',
    /Debian|Ubuntu/ => '/usr/lib/cgi-bin',
  }

  $log = $operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
  }

}
