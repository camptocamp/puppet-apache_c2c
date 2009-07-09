define apache::auth::htpasswd (
  $ensure="present", 
  $vhost=false,
  $userFileLocation=false,
  $userFileName="htpasswd",
  $username,
  $md5Password=false,
  $clearPassword=false){
 
  if $userFileLocation {
    if defined(File[$userFileLocation]) {
      $_authUserFile = "${userFileLocation}/${userFileName}"
    } else {
      fail "location $userFileLocation is not defined !"
    } 
  } else {
    if $vhost {
      $_authUserFile = "/var/www/${vhost}/private/${userFileName}"
    } else {
      fail "parameter vhost is require !"
    }
  }
  
  case $ensure {

    'present': {
      if $md5Password and $clearPassword {
        fail "choose only one of md5Password OR clearPassword !"
      }

      if !$md5Password and !$clearPassword  {
        fail "choose one of md5Password OR clearPassword !"
      }

      if $md5Password {
        exec {"! test -f $_authUserFile && OPT='-c'; htpasswd -bp \$OPT $_authUserFile $username '$md5Password'":
          unless => "grep -q $username $_authUserFile",
          require => File[$userFileLocation],
        }
      }

      if $clearPassword {
        exec {"! test -f $_authUserFile && OPT='-c'; htpasswd -bm \$OPT $_authUserFile $username $clearPassword":
          unless => "grep -q $username $_authUserFile",
          require => File[$userFileLocation],
        }
      }
    }

    'absent': {
      exec {"htpasswd -D $_authUserFile $username":
        onlyif => "grep -q $username $_authUserFile",
        notify => Exec["delete $_authUserFile if empty"],
      }

      exec {"delete $_authUserFile if empty":
        command => "rm -f $_authUserFile",
        onlyif => "wc -l $_authUserFile |grep -q 0",
        refreshonly => true,
      } 
    }
  }
}
