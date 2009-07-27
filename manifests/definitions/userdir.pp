define apache::userdirinstance ($ensure=present, $vhost) {
  file {"/var/www/${vhost}/conf/userdir.conf":
    ensure => $ensure,
    source => 'puppet:///apache/userdir.conf',
    require => File["/var/www/${vhost}/conf"],
    notify => Exec["apache-graceful"],
  }
}
