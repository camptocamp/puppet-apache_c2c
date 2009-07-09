define apache::auth::htgroup (
  $ensure="present", 
  $vhost=false,
  $groupFileLocation=false,
  $groupFileName="htgroup",
  $groupname,
  $members){
 
  if $groupFileLocation {
    if defined(File[$groupFileLocation]) {
      $_authGroupFile = "${groupFileLocation}/${groupFileName}"
    } else {
      fail "location $groupFileLocation is not defined !"
    } 
  } else {
    if $vhost {
      $_authGroupFile = "/var/www/${vhost}/private/${groupFileName}"
    } else {
      fail "parameter vhost is require !"
    }
  }
  
  case $ensure {

    'present': {
      exec {"! test -f $_authGroupFile && OPT='-c'; htgroup \$OPT $_authGroupFile $groupname $members":
        unless => "grep -q $groupname $_authGroupFile",
      }
    }

    'absent': {
      exec {"htgroup -D $_authGroupFile $groupname":
        onlyif => "grep -q $groupname $_authGroupFile",
        notify => Exec["delete $_authGroupFile if empty"],
      }

      exec {"delete $_authGroupFile if empty":
        command => "rm -f $_authGroupFile",
        onlyif => "wc -l $_authGroupFile |grep -q 0",
        refreshonly => true,
      } 
    }
  }
}
