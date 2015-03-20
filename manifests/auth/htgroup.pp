define apache_c2c::auth::htgroup(
  $groupname,
  $members,
  $ensure              = 'present',
  $vhost               = false,
  $group_file_location = false,
  $group_file_name     = 'htgroup',
) {

  include ::apache_c2c::params

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if $group_file_location {
    $_group_file_location = $group_file_location
  } else {
    if $vhost {
      $_group_file_location = "${wwwroot}/${vhost}/private"
    } else {
      fail 'parameter vhost is require !'
    }
  }

  $_auth_group_file = "${_group_file_location}/${group_file_name}"

  case $ensure {

    'present': {
      exec {"test -f ${_auth_group_file} || OPT='-c'; htgroup \$OPT ${_auth_group_file} ${groupname} ${members}":
        unless  => "egrep -q '^${groupname}: ${members}$' ${_auth_group_file}",
        require => File[$_group_file_location],
      }
    }

    'absent': {
      exec {"htgroup -D ${_auth_group_file} ${groupname}":
        onlyif => "egrep -q '^${groupname}:' ${_auth_group_file}",
        notify => Exec["delete ${_auth_group_file} after remove ${groupname}"],
      }

      exec {"delete ${_auth_group_file} after remove ${groupname}":
        command     => "rm -f ${_auth_group_file}",
        onlyif      => "wc -l ${_auth_group_file} | egrep -q '^0[^0-9]'",
        refreshonly => true,
      }
    }

    default: {}
  }
}
