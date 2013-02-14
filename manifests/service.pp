# Fake class for foreman with passenger mode enabled
# this is very ugly...

class apache::service {
  exec { 'reload-apache':
    command     => $httpd_reload_cmd,
    path        => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
    require     => Service['apache'],
    refreshonly => true,
  }
}
