define apache::module ($ensure='present') {

  case $operatingsystem {
    redhat,CentOS :  {
      $wwwconf = "/etc/httpd"
      $a2enmod_deps = [Package["apache"], File["/etc/httpd/mods-available"], File["/etc/httpd/mods-enabled"], File["/usr/local/sbin/a2enmod"], File["/usr/local/sbin/a2dismod"]]

      if $selinux == "true" {
        apache::redhat::selinux {$name: }
      }
    }
    debian :  {
      $wwwconf = "/etc/apache2"
      $a2enmod_deps = Package["apache"]
    }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        command => $operatingsystem ? {
          RedHat => "/usr/local/sbin/a2enmod ${name}",
          CentOS => "/usr/local/sbin/a2enmod ${name}",
          default => "/usr//sbin/a2enmod ${name}"
        },
          
        unless  => "/bin/sh -c '[ -L ${wwwconf}/mods-enabled/${name}.load ] \\
          && [ ${wwwconf}/mods-enabled/${name}.load -ef ${wwwconf}/mods-available/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service["apache"],
      }
    }
    'absent': {
      exec { "a2dismod ${name}":
        command => $operatingsystem ? {
          RedHat => "/usr/local/sbin/a2dismod ${name}",
          CentOS => "/usr/local/sbin/a2dismod ${name}",
          default => "/usr//sbin/a2dismod ${name}"
        },
        
        onlyif  => "/bin/sh -c '[ -L ${wwwconf}/mods-enabled/${name}.load ] \\
          || [ -e ${wwwconf}/mods-enabled/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service["apache"],
       }
    }
    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}
