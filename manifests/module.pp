define apache_c2c::module ($ensure='present') {

  include apache_c2c::params

  $a2enmod_deps = $::operatingsystem ? {
    /RedHat|CentOS/ => [
      Package['apache'],
      File['/etc/httpd/mods-available'],
      File['/etc/httpd/mods-enabled'],
      File['/usr/local/sbin/a2enmod'],
      File['/usr/local/sbin/a2dismod']
    ],
    /Debian|Ubuntu/ => Package['apache'],
  }

  if $::selinux == 'true' and $ensure == 'present' {
    apache_c2c::redhat::selinux {$name: }
  }

  $commands_path = $::osfamily ? {
    'RedHat' => '/usr/local/sbin/',
    'Debian' => '/usr/sbin/',
  }

  case $ensure {
    'present' : {
      exec { "a2enmod ${name}":
        command => "${commands_path}/a2enmod ${name}",
        unless  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/mods-enabled/${name}.load ] \\
          && [ ${apache_c2c::params::conf}/mods-enabled/${name}.load -ef ${apache_c2c::params::conf}/mods-available/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service['apache'],
      }
    }

    'absent': {
      exec { "a2dismod ${name}":
        command => "${commands_path}/a2dismod ${name}",
        onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/mods-enabled/${name}.load ] \\
          || [ -e ${apache_c2c::params::conf}/mods-enabled/${name}.load ]'",
        require => $a2enmod_deps,
        notify  => Service['apache'],
      }
    }

    default: {
      fail ( "Unknown ensure value: '${ensure}'" )
    }
  }
}
