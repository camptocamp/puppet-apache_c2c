class apache::params {

  $pkg = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd',
    /Debian|Ubuntu/ => 'apache2',
  }

  $root = $apache_root ? {
    "" => $::operatingsystem ? {
      /RedHat|CentOS/ => '/var/www/vhosts',
      /Debian|Ubuntu/ => '/var/www',
    },
    default => $apache_root
  }

  $user = $::operatingsystem ? {
    /RedHat|CentOS/ => 'apache',
    /Debian|Ubuntu/ => 'www-data',
  }

  $conf = $::operatingsystem ? {
    /RedHat|CentOS/ => '/etc/httpd',
    /Debian|Ubuntu/ => '/etc/apache2',
  }

  $log = $::operatingsystem ? {
    /RedHat|CentOS/ => '/var/log/httpd',
    /Debian|Ubuntu/ => '/var/log/apache2',
  }

  $access_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/access_log",
    /Debian|Ubuntu/ => "${log}/access.log",
  }

  $error_log = $::operatingsystem ? {
    /RedHat|CentOS/ => "${log}/error_log",
    /Debian|Ubuntu/ => "${log}/error.log",
  }

}
