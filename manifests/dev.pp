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
  $pkg_name = $::operatingsystem ? {
    /RedHat|CentOS/ => 'httpd-devel',
    /Debian|Ubuntu/ => 'apache2-threaded-dev',
  }
  package { 'apache-devel':
    ensure  => present,
    name    => $pkg_name,
    require => Package['gcc'],
  }
}
