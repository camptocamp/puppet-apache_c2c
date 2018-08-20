# == Class: apache::collectd
#
# Configures collectd's apache plugin. This gathers data from apache's
# server-status and stores it in rrd files, from which you can make nice
# graphs.
#
# You will need collectd up and running, which can be cone using the
# puppet-collectd module.
#
# Requires:
# - Class["collectd"]
#
# Usage:
#   include apache
#   include collectd
#   include apache_c2c::collectd
#
class apache_c2c::collectd {
  # trick to check which collectd module we are using
  include ::monitoring::apache_c2c
}
