# = Class: apache
#
# Installs apache, ensures a few useful modules are installed (see
# apache_c2c::base), ensures that the service is running and the logs get rotated.
#
# By including subclasses where distro specific stuff is handled, it ensure that
# the apache class behaves the same way on diffrent distributions.
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
# == Example ===
#
#   include apache
#
class apache_c2c (
  $root            = $apache_c2c::params::root,
  $service_ensure  = 'running',
  $service_enable  = true,
  $disable_port80  = false,
  $default_vhost   = true,
) inherits ::apache_c2c::params {

  validate_absolute_path ($root)
  validate_re ($service_ensure, 'running|stopped|unmanaged')
  validate_bool ($service_enable)
  validate_bool ($disable_port80)

  case $::operatingsystem {
    Debian,Ubuntu:  { include apache_c2c::debian}
    RedHat,CentOS:  { include apache_c2c::redhat}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
