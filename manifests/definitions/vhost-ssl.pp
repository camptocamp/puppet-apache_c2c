define apache::vhost-ssl ($ensure, $ip_address = "*", $htdocs=false, $conf=false, $user="$wwwuser", $group="root", $mode=2570, $aliases = [], $cert = "apache.pem", $certkey = "absent", $cacert = "absent", $certchain = "absent") {

  apache::vhost {$name:
    ensure         => $ensure,
    config_content => template("apache/vhost-ssl.erb"),
    aliases        => $aliases,
    htdocs         => $htdocs,
    conf           => $conf,
    user           => $user,
    group          => $group,
    mode           => $mode,
  }

  file { "${wwwroot}/${name}/ssl":
    ensure => directory,
    owner  => "root",
    group  => "root",
    mode   => 700,
    seltype => "cert_t",
  }

  exec { "generate-ssl-cert-$name":
    command => "/usr/local/sbin/generate-ssl-cert.sh $name /etc/ssl/ssleay.cnf ${wwwroot}/${name}/ssl/apache.pem",
    creates => "${wwwroot}/${name}/ssl/apache.pem",
    require => [
      File["${wwwroot}/${name}/ssl"],
      File["/usr/local/sbin/generate-ssl-cert.sh"],
      File["/etc/ssl/ssleay.cnf"]
    ],
  }

  file { "${wwwroot}/${name}/ssl/apache.pem":
    owner => "root",
    group => "root",
    mode  => 750,
    seltype => "cert_t",
    require => [File["${wwwroot}/${name}/ssl"], Exec["generate-ssl-cert-$name"]],
  }

}
