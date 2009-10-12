import "classes/*.pp"
import "definitions/*.pp"

class apache {
  case $operatingsystem {
    Debian:  { include apache::debian}
    RedHat,CentOS:  { include apache::redhat}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}

class apache::ssl inherits apache {
  case $operatingsystem {
    Debian:  { include apache::ssl::debian}
    RedHat,CentOS:  { include apache::ssl::redhat}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}

class apache::webdav::ssl inherits apache::ssl {
  case $operatingsystem {
    Debian:  { include apache::webdav::ssl::debian}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
