class apache_c2c::webdav::ssl inherits apache_c2c::ssl {
  case $::operatingsystem {
    Debian,Ubuntu:  { include apache_c2c::webdav::ssl::debian}
    default: { fail "Unsupported operatingsystem ${::operatingsystem}" }
  }
}
