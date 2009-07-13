define apache::vhost-ssl (
  $ensure=present,
  $config_file=false,
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $user="$wwwuser",
  $admin="$admin",
  $group="root",
  $mode=2570,
  $aliases=[],
  $ip_address="*",
  $cert="apache.pem",
  $certkey="absent",
  $cacert="absent",
  $certchain="absent",
  $sslonly=false
) {

  case $operatingsystem {
    redhat : {
      $wwwuser =  $user ? {
        "" => "apache",
        default => $user,
      }
      $wwwroot = "/var/www/vhosts"
      $confroot = "/etc/httpd"
    }
    debian : {
      $wwwuser =  $user ? {
        "" => "www-data",
        default => $user,
      }
      $wwwroot = "/var/www"
      $confroot = "/etc/apache2"
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }    
  
  apache::vhost {$name:
    ensure         => $ensure,
    config_file    => $config_file,
    config_content => $config_content ? {
      false => $sslonly ? {
        true => template("apache/vhost-ssl.erb"),
        default => template("apache/vhost.erb", "apache/vhost-ssl.erb"),
      },
      default      => $config_content,
    },
    aliases        => $aliases,
    htdocs         => $htdocs,
    conf           => $conf,
    readme         => $readme,
    user           => $user,
    admin          => $admin,
    group          => $group,
    mode           => $mode,
    aliases        => $aliases,
  }

  if $sslonly {
    exec { "disable default site":
      command => $operatingsystem ? {
        Debian => "/usr/sbin/a2dissite default",
        RedHat => "/usr/local/sbin/a2dissite 000-default",
      },
      onlyif => "/usr/bin/test -L ${confroot}/sites-enabled/000-default",
      notify => Exec["apache-graceful"],
    }
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
