define apache_c2c::auth::htgroup(
  $groupname,
  $members,
  $ensure            = 'present',
  $vhost             = false,
  $groupFileLocation = false,
  $groupFileName     = 'htgroup',
) {

  include apache_c2c::params

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if $groupFileLocation {
    $_groupFileLocation = $groupFileLocation
  } else {
    if $vhost {
      $_groupFileLocation = "${wwwroot}/${vhost}/private"
    } else {
      fail 'parameter vhost is require !'
    }
  }

  $_authGroupFile = "${_groupFileLocation}/${groupFileName}"

  case $ensure {

    'present': {
      exec {"test -f ${_authGroupFile} || OPT='-c'; htgroup \$OPT ${_authGroupFile} ${groupname} ${members}":
        unless  => "egrep -q '^${groupname}: ${members}$' ${_authGroupFile}",
        require => File[$_groupFileLocation],
      }
    }

    'absent': {
      exec {"htgroup -D ${_authGroupFile} ${groupname}":
        onlyif => "egrep -q '^${groupname}:' ${_authGroupFile}",
        notify => Exec["delete ${_authGroupFile} after remove ${groupname}"],
      }

      exec {"delete ${_authGroupFile} after remove ${groupname}":
        command     => "rm -f ${_authGroupFile}",
        onlyif      => "wc -l ${_authGroupFile} | egrep -q '^0[^0-9]'",
        refreshonly => true,
      }
    }

    default: {}
  }
}
