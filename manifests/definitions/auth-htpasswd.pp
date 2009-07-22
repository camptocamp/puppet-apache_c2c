define apache::auth::htpasswd (
  $ensure="present", 
  $vhost=false,
  $userFileLocation=false,
  $userFileName="htpasswd",
  $username,
  $md5Password=false,
  $clearPassword=false){

   case $operatingsystem {
    redhat : { $wwwroot = "/var/www/vhosts" }
    debian : { $wwwroot = "/var/www" }
    default : { fail "Unsupported operatingsystem ${operatingsystem}" }
  } 
 
  if $userFileLocation {
    $_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $_userFileLocation = "${wwwroot}/${vhost}/private"
    } else {
      fail "parameter vhost is require !"
    }
  }
  
  $_authUserFile = "${_userFileLocation}/${userFileName}"
  
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
          require => File[$_userFileLocation],
        }
      }

      if $clearPassword {
        exec {"! test -f $_authUserFile && OPT='-c'; htpasswd -bm \$OPT $_authUserFile $username $clearPassword":
          unless => "grep -q $username $_authUserFile",
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
