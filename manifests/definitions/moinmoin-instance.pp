define apache::moinmoin::instance ($ensure=ensure,$vhost) {

  file {"/var/www/${vhost}/conf/wiki-${name}.conf":
    ensure  => $ensure,
    content => template("apache/moinmoin-instance.erb"),
    notify  => Exec["apache-graceful"],
  }

}
