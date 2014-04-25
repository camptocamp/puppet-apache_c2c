class apache_c2c::params {

  $pkg = $::osfamily ? {
    RedHat => 'httpd',
    Debian => 'apache2',
  }

  $root = $::osfamily ? {
    RedHat => '/var/www/vhosts',
    Debian => '/var/www',
  }

  $user = $::osfamily ? {
    RedHat => 'apache',
    Debian => 'www-data',
  }

  $group = $::osfamily ? {
    RedHat => 'apache',
    Debian => 'www-data',
  }

  $conf = $::osfamily ? {
    RedHat => '/etc/httpd',
    Debian => '/etc/apache2',
  }

  $log = $::osfamily ? {
    RedHat => '/var/log/httpd',
    Debian => '/var/log/apache2',
  }

  $access_log = $::osfamily ? {
    RedHat => "${log}/access_log",
    Debian => "${log}/access.log",
  }

  $a2ensite = $::osfamily ? {
    RedHat => '/usr/local/sbin/a2ensite',
    Debian => '/usr/sbin/a2ensite',
  }

  $error_log = $::osfamily ? {
    RedHat => "${log}/error_log",
    Debian => "${log}/error.log",
  }

}
