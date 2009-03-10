define apache::module ($ensure='present') {
  case $ensure {
    'present' : {
      exec { "/usr/sbin/a2enmod ${name}":
        unless  => "/bin/sh -c '[ -L ${mods}-enabled/${name}.load ] \\
          && [ ${mods}-enabled/${name}.load -ef ${mods}-available/${name}.load ]'",
        require => Package["apache2"],
        notify  => Service["apache2"],
      }
    }
    'absent': {
      exec { "/usr/sbin/a2dismod ${name}": 
        onlyif  => "/bin/sh -c '[ -L ${mods}-enabled/${name}.load ] \\
          && [ ${mods}-enabled/${name}.load -ef ${mods}-available/${name}.load ]'",
        require => Package["apache2"],
        notify  => Service["apache2"],
       }
    }
    default: { 
      err ( "Unknown ensure value: '${ensure}'" ) 
    }
  }
}

#define apache::module ($ensure='present') {
#  case $ensure {
#    'present' : {
#      exec { "a2enmod ${name}":
#        unless  => "/bin/sh -c '[ -L $wwwconf/mods-enabled/${name}.load ] \\
#          && [ $wwwconf/mods-enabled/${name}.load -ef $wwwconf/mods-available/${name}.load ]'",
#        notify  => Service["$wwwpkgname"],
#      }
#    }
#    'absent': {
#      exec { "a2dismod ${name}": 
#        onlyif  => "/bin/sh -c '[ -L $wwwconf/mods-enabled/${name}.load ] \\
#          && [ $wwwconf/mods-enabled/${name}.load -ef $wwwconf/mods-available/${name}.load ]'",
#        require => [Package["$wwwpkgname"], File["$wwwconf/mods-available"], File["$wwwconf/mods-enabled"]],
#        notify  => Service["$wwwpkgname"],
#       }
#    }
#    default: { 
#      err ( "Unknown ensure value: '${ensure}'" ) 
#    }
#  }
#}
