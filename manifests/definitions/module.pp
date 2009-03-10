define apache::module ($ensure='present') {

  case $operatingsystem {
    redhat :  { $wwwconf = "/etc/httpd" }
    debian :  { $wwwconf = "/etc/apache2" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        unless  => "/bin/sh -c '[ -L ${wwwconf}/mods-enabled/${name}.load ] \\
          && [ ${wwwconf}/mods-enabled/${name}.load -ef ${wwwconf}/mods-available/${name}.load ]'",
        require => Package["apache"],
        notify  => Service["apache"],
      }
    }
    'absent': {
      exec { "a2dismod ${name}": 
        onlyif  => "/bin/sh -c '[ -L ${wwwconf}/mods-enabled/${name}.load ] \\
          && [ ${wwwconf}/mods-enabled/${name}.load -ef ${wwwconf}/mods-available/${name}.load ]'",
        require => Package["apache"],
        notify  => Service["apache"],
       }
    }
    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}
