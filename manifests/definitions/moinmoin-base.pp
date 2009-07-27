define apache::moinmoin::base ($ensure=ensure) {

  file {"/var/www/${name}/conf/wiki-base.conf":
    ensure  => $ensure,
    content => template("apache/moinmoin-base.erb"),
    notify  => Exec["apache-graceful"],
  }

}
