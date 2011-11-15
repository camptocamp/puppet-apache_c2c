class apache::webdav::ssl inherits apache::ssl {
  case $operatingsystem {
    Debian,Ubuntu:  { include apache::webdav::ssl::debian}
    default: { notice "Unsupported operatingsystem ${operatingsystem}" }
  }
}
