define apache::auth::htpasswd (
  $ensure="present", 
  $vhost=false,
  $userFileLocation=false,
  $userFileName="htpasswd",
  $username,
  $cryptPassword=false,
  $clearPassword=false){

  include apache::params
 
  if $userFileLocation {
    $_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $_userFileLocation = "${apache::params::root}/${vhost}/private"
    } else {
      fail "parameter vhost is require !"
    }
  }
  
  $_authUserFile = "${_userFileLocation}/${userFileName}"
  
  case $ensure {

    'present': {
      if $cryptPassword and $clearPassword {
        fail "choose only one of cryptPassword OR clearPassword !"
      }

      if !$cryptPassword and !$clearPassword  {
        fail "choose one of cryptPassword OR clearPassword !"
      }

      if $cryptPassword {
        exec {"! test -f $_authUserFile && OPT='-c'; htpasswd -bp \$OPT $_authUserFile $username '$cryptPassword'":
          unless => "grep -q ${username}:${cryptPassword} $_authUserFile",
          require => File[$_userFileLocation],
        }
      }

      if $clearPassword {
        exec {"! test -f $_authUserFile && OPT='-c'; htpasswd -b \$OPT $_authUserFile $username $clearPassword":
          unless => "grep $username $_authUserFile && grep ${username}:\$(mkpasswd -S \$(grep $username $_authUserFile |cut -d : -f 2 |cut -c-2) $clearPassword) $_authUserFile",
          require => File[$_userFileLocation],
        }
      }
    }

    'absent': {
      exec {"htpasswd -D $_authUserFile $username":
        onlyif => "grep -q $username $_authUserFile",
        notify => Exec["delete $_authUserFile after remove $username"],
      }

      exec {"delete $_authUserFile after remove $username":
        command => "rm -f $_authUserFile",
        onlyif => "wc -l $_authUserFile |grep -q 0",
        refreshonly => true,
      } 
    }
  }
}
