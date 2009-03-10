import "classes/*.pp"
import "definitions/*.pp"

class apache {
  case $operatingsystem {
    Debian:  { include apache::debian}
    RedHat:  { include apache::redhat}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}

class apache::ssl inherits apache {
  case $operatingsystem {
    Debian:  { include apache::ssl::debian}
    RedHat:  { include apache::ssl::redhat}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
