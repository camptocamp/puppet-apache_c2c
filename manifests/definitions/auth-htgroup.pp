define apache::auth::htgroup (
  $ensure="present", 
  $vhost=false,
  $groupFileLocation=false,
  $groupFileName="htgroup",
  $groupname,
  $members){

  include apache::params

  if $groupFileLocation {
    $_groupFileLocation = $groupFileLocation
  } else {
    if $vhost {
      $_groupFileLocation = "${apache::params::root}/${vhost}/private"
    } else {
      fail "parameter vhost is require !"
    }  
  }

  $_authGroupFile = "${_groupFileLocation}/${groupFileName}"
  
  case $ensure {

    'present': {
      exec {"! test -f $_authGroupFile && OPT='-c'; htgroup \$OPT $_authGroupFile $groupname $members":
        unless => "grep -qi '^${groupname}: ${members}$' ${_authGroupFile}",
        require => File[$_groupFileLocation],
      }
    }

    'absent': {
      exec {"htgroup -D $_authGroupFile $groupname":
        onlyif => "grep -q $groupname $_authGroupFile",
        notify => Exec["delete $_authGroupFile after remove $groupname"],
      }

      exec {"delete $_authGroupFile after remove $groupname":
        command => "rm -f $_authGroupFile",
        onlyif => "wc -l $_authGroupFile |grep -q 0",
        refreshonly => true,
      } 
    }
  }
}
