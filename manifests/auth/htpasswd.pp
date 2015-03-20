define apache_c2c::auth::htpasswd (
  $username,
  $ensure           = 'present',
  $vhost            = false,
  $user_file_location = false,
  $user_file_name     = 'htpasswd',
  $crypt_password    = false,
  $clear_password    = false,
) {

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if $user_file_location {
    $_user_file_location = $user_file_location
  } else {
    if $vhost {
      $_user_file_location = "${wwwroot}/${vhost}/private"
    } else {
      fail "parameter vhost is required for '${name}'"
    }
  }

  $_auth_user_file = "${_user_file_location}/${user_file_name}"

  case $ensure {

    'present': {
      if $crypt_password and $clear_password {
        fail "choose only one of crypt_password OR clear_password for '${name}'"
      }

      if !$crypt_password and !$clear_password  {
        fail "crypt_password or clear_password missing for '${name}'"
      }

      if $crypt_password {
        exec {"test -f ${_auth_user_file} || OPT='-c'; htpasswd -bp \${OPT} ${_auth_user_file} ${username} '${crypt_password}'":
          unless  => "grep -q '${username}:${crypt_password}' ${_auth_user_file}",
          require => File[$_user_file_location],
        }
      }

      if $clear_password {
        exec {"test -f ${_auth_user_file} || OPT='-c'; htpasswd -b \$OPT ${_auth_user_file} ${username} ${clear_password}":
          unless  => "egrep '^${username}:' ${_auth_user_file} && grep ${username}:\$(mkpasswd -S \$(egrep '^${username}:' ${_auth_user_file} |cut -d : -f 2 |cut -c-2) ${clear_password}) ${_auth_user_file}",
          require => File[$_user_file_location],
        }
      }
    }

    'absent': {
      exec {"htpasswd -D ${_auth_user_file} ${username}":
        onlyif => "egrep -q '^${username}:' ${_auth_user_file}",
        notify => Exec["delete ${_auth_user_file} after remove ${username}"],
      }

      exec {"delete ${_auth_user_file} after remove ${username}":
        command     => "rm -f ${_auth_user_file}",
        onlyif      => "wc -l ${_auth_user_file} | egrep -q '^0[^0-9]'",
        refreshonly => true,
      }
    }

    default: {}
  }
}
