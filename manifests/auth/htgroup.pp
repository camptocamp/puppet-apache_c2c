define apache::auth::htgroup (
  $ensure="present", 
  $vhost=false,
  $groupFileLocation=false,
  $groupFileName="htgroup",
  $groupname,
  $members){

  include apache::params

  if $groupFileLocation {
    $groupFileLocation_real = $groupFileLocation
  } else {
    if $vhost {
      $groupFileLocation_real = "${apache::params::root}/${vhost}/private"
    } else {
      fail "parameter vhost is require !"
    }  
  }

  $authGroupFile_real = "${groupFileLocation_real}/${groupFileName}"
  
  case $ensure {

    'present': {
      exec {"! test -f $authGroupFile_real && OPT='-c'; htgroup \$OPT $authGroupFile_real $groupname $members":
        unless => "grep -qi '^${groupname}: ${members}$' ${authGroupFile_real}",
        require => File[$groupFileLocation_real],
      }
    }

    'absent': {
      exec {"htgroup -D $authGroupFile_real $groupname":
        onlyif => "grep -q $groupname $authGroupFile_real",
        notify => Exec["delete $authGroupFile_real after remove $groupname"],
      }

      exec {"delete $authGroupFile_real after remove $groupname":
        command => "rm -f $authGroupFile_real",
        onlyif => "wc -l $authGroupFile_real |grep -q 0",
        refreshonly => true,
      } 
    }
  }
}
