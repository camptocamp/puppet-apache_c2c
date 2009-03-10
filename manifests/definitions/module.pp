define apache::module ($ensure='present') {
  
  $wwwconf = $operatingsystem ? {
    Redhat  => "/etc/httpd",
    Debian  => "/etc/apache2",
    default => { notice "Unsupported operatingsystem ${operatingsystem}",
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        unless  => "/bin/sh -c '[ -L ${wwwconf}/${name}.load ] \\
          && [ ${wwwconf}/mods-enabled/${name}.load -ef ${wwwconf}/mods-available/${name}.load ]'",
        require => Package["apache2"],
        notify  => Service["apache2"],
      }
    }
    'absent': {
      exec { "a2dismod ${name}": 
        onlyif  => "/bin/sh -c '[ -L ${wwwconf}/mods-enabled/${name}.load ] \\
          && [ ${wwwconf}/mods-enabled/${name}.load -ef ${wwwconf}/mods-available/${name}.load ]'",
        require => Package["apache2"],
        notify  => Service["apache2"],
       }
    }
    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}
