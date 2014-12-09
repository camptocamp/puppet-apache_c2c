# == Class: apache::dev
#
# Installs package(s) required to build apache modules using apxs.
#
# Limitation: currently only works on redhat.
#
# Example usage:
#
#   include apache_c2c::dev
#
class apache_c2c::dev {
  $pkg_name = $::osfamily ? {
    'RedHat' => 'httpd-devel',
    'Debian' => 'apache2-threaded-dev',
  }
  package { 'apache-devel':
    ensure  => present,
    name    => $pkg_name,
    require => Package['gcc'],
  }
}
