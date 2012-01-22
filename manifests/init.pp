/*

== Class: apache

Installs apache, ensures a few useful modules are installed (see apache::base),
ensures that the service is running and the logs get rotated.

By including subclasses where distro specific stuff is handled, it ensure that
the apache class behaves the same way on diffrent distributions.

Example usage:

  $apache_port = '127.0.0.1:8080'
  include apache

Parameters:

  $apache_port to specify on which main port Apache will listen. 
  Defaults to '*:80'

*/
class apache {
  case $operatingsystem {
    Debian,Ubuntu:  { include apache::debian}
    RedHat,CentOS:  { include apache::redhat}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
