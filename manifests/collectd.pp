/*
== Class: apache::collectd

Configures collectd's apache plugin. This gathers data from apache's
server-status and stores it in rrd files, from which you can make nice
graphs.

You will need collectd up and running, which can be cone using the
puppet-collectd module.

Requires:
- Class["collectd"]

Usage:
  include apache
  include collectd
  include apache::collectd

*/
class apache::collectd {

  if ($::operatingsystem == "RedHat" or $::operatingsystem == "CentOS") and $lsbmajdistrelease > "4" {

    package { "collectd-apache":
      ensure => present,
      before => Collectd::Plugin["apache"],
    }
  }

  collectd::plugin { "apache":
    lines   => ['URL "http://localhost/server-status?auto"'],
    require => Package["curl"],
  }

}
