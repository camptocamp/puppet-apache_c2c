class apache_c2c::webdav::ssl inherits apache_c2c::ssl {
  case $::osfamily {
    'Debian':  { include ::apache_c2c::webdav::ssl::debian}
    default: { fail "Unsupported osfamily ${::osfamily}" }
  }
}
