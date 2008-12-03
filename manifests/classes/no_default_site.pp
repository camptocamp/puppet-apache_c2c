class apache::no_default_site inherits apache::base {
  exec { "/usr/sbin/a2dissite default":
    onlyif => "/usr/bin/test -L /etc/apache2/sites-enabled/000-default",
    notify => Exec["apache2-graceful"],
  }
}
