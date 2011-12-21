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
    $userFileLocation_real = $userFileLocation
  } else {
    if $vhost {
      $userFileLocation_real = "${apache::params::root}/${vhost}/private"
    } else {
      fail "parameter vhost is require !"
    }
  }
  
  $authUserFile_real = "${userFileLocation_real}/${userFileName}"
  
  case $ensure {

    'present': {
      if $cryptPassword and $clearPassword {
        fail "choose only one of cryptPassword OR clearPassword !"
      }

      if !$cryptPassword and !$clearPassword  {
        fail "choose one of cryptPassword OR clearPassword !"
      }

      if $cryptPassword {
        exec {"! test -f $authUserFile_real && OPT='-c'; htpasswd -bp \$OPT $authUserFile_real $username '$cryptPassword'":
          unless => "grep -q ${username}:${cryptPassword} $authUserFile_real",
          require => File[$userFileLocation_real],
        }
      }

      if $clearPassword {
        exec {"! test -f $authUserFile_real && OPT='-c'; htpasswd -b \$OPT $authUserFile_real $username $clearPassword":
          unless => "grep $username $authUserFile_real && grep ${username}:\$(mkpasswd -S \$(grep $username $authUserFile_real |cut -d : -f 2 |cut -c-2) $clearPassword) $authUserFile_real",
          require => File[$userFileLocation_real],
        }
      }
    }

    'absent': {
      exec {"htpasswd -D $authUserFile_real $username":
        onlyif => "grep -q $username $authUserFile_real",
        notify => Exec["delete $authUserFile_real after remove $username"],
      }

      exec {"delete $authUserFile_real after remove $username":
        command => "rm -f $authUserFile_real",
        onlyif => "wc -l $authUserFile_real |grep -q 0",
        refreshonly => true,
      } 
    }
  }
}
