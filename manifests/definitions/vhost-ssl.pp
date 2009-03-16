define apache::vhost-ssl ($ensure, $ip_address = "*", $htdocs=false, $conf=false, $user="$wwwuser", $group="root", $mode=2570, $aliases = [], $cert = "apache.pem", $certkey = "absent", $cacert = "absent", $certchain = "absent") {

  case $operatingsystem {
    redhat : {
      $wwwuser =  $user ? {
        "" => "apache",
        default => $user,
      }
      $wwwroot = "/var/www/vhosts"
    }
    debian : {
      $wwwuser =  $user ? {
        "" => "www-data",
        default => $user,
      }
      $wwwroot = "/var/www"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }    

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

  if $ensure == "present" {
    file { "${wwwroot}/${name}/ssl":
      ensure => directory,
      owner  => "root",
      group  => "root",
      mode   => 700,
      seltype => "cert_t",
      require => [File["${wwwroot}/${name}"]],
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
}
