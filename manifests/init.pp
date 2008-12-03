# Note: These variables get available only if the module get explicitly loaded.
#
# example which works:
#
# import "apache"
# include apache::base

case $operatingsystem {
  RedHat: {
    $wwwuser = "apache"
    $wwwroot = "/var/www/vhosts"
    $wwwcgi = "/var/www/cgi-bin"
    $wwwconf = "/etc/httpd"
    $wwwpkgname = "httpd"
  }

  Debian: {
    $wwwuser = "www-data"
    $wwwroot = "/var/www/"
    $wwwcgi = "/usr/lib/cgi-bin"
    $wwwconf = "/etc/apache2"
    $wwwpkgname = "apache2"
  }
}

import "classes/*.pp"
import "definitions/*.pp"
