define apache::module ($ensure='present') {
  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        unless  => "/bin/sh -c '[ -L $wwwconf/mods-enabled/${name}.load ] \\
          && [ $wwwconf/mods-enabled/${name}.load -ef $wwwconf/mods-available/${name}.load ]'",
        require => [Package["$wwwpkgname"], File["$wwwconf/mods-available"], File["$wwwconf/mods-enabled"]],
        notify  => Service["$wwwpkgname"],
      }
    }
    'absent': {
      exec { "a2dismod ${name}": 
        onlyif  => "/bin/sh -c '[ -L $wwwconf/mods-enabled/${name}.load ] \\
          && [ $wwwconf/mods-enabled/${name}.load -ef $wwwconf/mods-available/${name}.load ]'",
        require => [Package["$wwwpkgname"], File["$wwwconf/mods-available"], File["$wwwconf/mods-enabled"]],
        notify  => Service["$wwwpkgname"],
       }
    }
    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}
