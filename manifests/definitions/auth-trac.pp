define apache::auth::trac ($ensure, $vhost) {

  apache::auth::basic {"auth-trac-$name":
    ensure   => $ensure,
    authname => "Restricted Access",
    vhost    => $vhost,
    location => "/",
    userfile => "/srv/trac/projects/${name}/conf/htpasswd",
  }

}
