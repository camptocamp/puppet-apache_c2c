/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see apache::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  include apache

*/
class apache (
  $root            = $apache::params::root,
  $service_ensure  = 'running',
  $service_enable  = true,
  $disable_port80  = false,
) inherits ::apache::params {

  validate_absolute_path ($root)  
  validate_bool ($service_enable)
  validate_bool ($disable_port80)

  case $::operatingsystem {
    Debian,Ubuntu:  { include apache::debian}
    RedHat,CentOS:  { include apache::redhat}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
