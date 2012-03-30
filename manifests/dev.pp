#
# == Class: apache::dev
#
# Installs package(s) required to build apache modules using apxs.
#
# Limitation: currently only works on redhat.
#
# Example usage:
#
#   include apache::dev
#
class apache::dev {

  $apache_devel_package_name = $::operatingsystem ? {
    RedHat => 'httpd-devel',
    CentOS => 'httpd-devel',
  }

  package { 'apache-devel':
    ensure  => present,
    name    => $apache_devel_package_name,
    require => Package['gcc'],
  }
}
