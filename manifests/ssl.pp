# = Class: apache::ssl
#
# This class basically does the same thing the "apache" class does + enable
# mod_ssl.
#
# It also drops a little shell script in /usr/local/sbin/generate-ssl-cert.sh,
# which is used by apache::vhost-ssl to generate an SSL key and certificate.
# This script calls openssl with /var/www/<vhost>/ssl/ssleay.cnf as a template.
# The content of this file is influenced by a few class variables described
# below.
#
# == Class variables ==
#
# [*sslcert_country*]
#   Content of the "countryName" field in generated certificates. Setting this
#   field is mandatory.
#
# [*sslcert_state*]
#   Content of the "stateOrProvinceName" field in generated certificates.
#
# [*sslcert_locality*]
#   Content of the "localityName" field in generated certificates.
#
# [*sslcert_organization*]
#   Content of the "organizationName" field in generated certificates. Setting
#   this field is mandatory.
#
# [*sslcert_unit*]
#   Content of the "organizationalUnitName" field in generated certificates.
#
# [*sslcert_email*]
#   Content of the "emailAddress" field in generated certificates.
#
# == Parameters ===
#
# [*root*]
#   Root directory of vhosts, defaults to /var/www on Debian, /var/www/vhosts
#   on RedHat.
#
# [*service_ensure*]
#   Ensure value passed to the Apache service. Valid values are 'running'
#   (default), 'stopped', or 'unmanaged' (ensure is not set).
#
# [*service_enable*]
#   Enable value passed to the Apache service, defining the service's status
#   at boot. Valid values are true (default) and false.
#
# [*disable_port80*]
#   Disable the default HTTP port 80. Default is false (the port 80 is enabled).
#
# [*disable_port443*]
#   Disable the default HTTPS port 443. Default is false (the port 443 is
#   enabled).
#
# == Example ==
#
#  include apache_c2c::ssl
#
class apache_c2c::ssl (
  $root            = $apache_c2c::params::root,
  $service_ensure  = 'running',
  $service_enable  = true,
  $disable_port80  = false,
  $disable_port443 = false,
  $default_vhost   = true,
) inherits ::apache_c2c::params {

  validate_absolute_path ($root)
  validate_re ($service_ensure, 'running|stopped|unmanaged')
  validate_bool ($service_enable)
  validate_bool ($disable_port80)
  validate_bool ($disable_port443)

  class { '::apache_c2c':
    root           => $root,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
    disable_port80 => $disable_port80,
    default_vhost  => $default_vhost,
  }

  case $::operatingsystem {
    Debian,Ubuntu:  { include apache_c2c::ssl::debian}
    RedHat,CentOS:  { include apache_c2c::ssl::redhat}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
