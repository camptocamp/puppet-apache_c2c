# Note: These variables get available only if the module get explicitly loaded.
#
# example which works:
#
# import "apache"
# include apache::base

case $operatingsystem {
  Debian:  { include apache::debian}
  RedHat:  { include apache::redhat}
  default: { notice "Unsupported operatingsystem ${operatingsystem}" }
}
