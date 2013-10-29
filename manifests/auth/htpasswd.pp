define apache_c2c::auth::htpasswd (
  $username,
  $ensure           = 'present',
  $vhost            = false,
  $userFileLocation = false,
  $userFileName     = 'htpasswd',
  $cryptPassword    = false,
  $clearPassword    = false,
) {

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if $userFileLocation {
    $_userFileLocation = $userFileLocation
  } else {
    if $vhost {
      $_userFileLocation = "${wwwroot}/${vhost}/private"
    } else {
      fail "parameter vhost is required for '${name}'"
    }
  }

  $_authUserFile = "${_userFileLocation}/${userFileName}"

  case $ensure {

    'present': {
      if $cryptPassword and $clearPassword {
        fail "choose only one of cryptPassword OR clearPassword for '${name}'"
      }

      if !$cryptPassword and !$clearPassword  {
        fail "cryptPassword or clearPassword missing for '${name}'"
      }

      if $cryptPassword {
        exec {"test -f ${_authUserFile} || OPT='-c'; htpasswd -bp \${OPT} ${_authUserFile} ${username} '${cryptPassword}'":
          unless  => "grep -q '${username}:${cryptPassword}' ${_authUserFile}",
          require => File[$_userFileLocation],
        }
      }

      if $clearPassword {
        exec {"test -f ${_authUserFile} || OPT='-c'; htpasswd -b \$OPT ${_authUserFile} ${username} ${clearPassword}":
          unless  => "egrep '^${username}:' ${_authUserFile} && grep ${username}:\$(mkpasswd -S \$(egrep '^${username}:' ${_authUserFile} |cut -d : -f 2 |cut -c-2) ${clearPassword}) ${_authUserFile}",
          require => File[$_userFileLocation],
        }
      }
    }

    'absent': {
      exec {"htpasswd -D ${_authUserFile} ${username}":
        onlyif => "egrep -q '^${username}:' ${_authUserFile}",
        notify => Exec["delete ${_authUserFile} after remove ${username}"],
      }

      exec {"delete ${_authUserFile} after remove ${username}":
        command     => "rm -f ${_authUserFile}",
        onlyif      => "wc -l ${_authUserFile} | egrep -q '^0[^0-9]'",
        refreshonly => true,
      }
    }

    default: {}
  }
}
