class apache::webdav::ssl::debian inherits apache::webdav::base {

  case $::lsbdistcodename {
    etch: {
      # cf: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=420101
      file {"/var/lock/apache2":
        ensure  => directory,
        owner   => www-data,
        group   => root,
        mode    => 755,
      }
    }
  } 

}
