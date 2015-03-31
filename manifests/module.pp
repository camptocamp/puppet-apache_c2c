define apache_c2c::module ($ensure='present') {

  if $::apache_c2c::backend == 'puppetlabs' {

    if $ensure == 'present' {
      case $name {
        'ssl': {
          class { '::apache::mod::ssl':
            ssl_options => false,
          }
        }
        'status': {
          class { '::apache::mod::status':
            allow_from => ['localhost', 'ip6-localhost', '127.0.0.0/255.0.0.0',],
          }
        }
        default: {
          if defined("apache::mod::${name}") {
            include "::apache::mod::${name}"
            } else {
              apache::mod { $name: }
            }
        }
      }
    }
    # We don't need to do anything for ensure => absent,
    # the puppetlabs module purges unmanaged modules automatically

  } else {
    include ::apache_c2c::params

    $a2enmod_deps = $::osfamily ? {
      'RedHat' => [
        Package['httpd'],
        File['/etc/httpd/mods-available'],
        File['/etc/httpd/mods-enabled'],
        File['/usr/local/sbin/a2enmod'],
        File['/usr/local/sbin/a2dismod']
      ],
      'Debian' => Package['httpd'],
    }

    if str2bool($::selinux) == true and $ensure == 'present' {
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
          notify  => Service['httpd'],
        }
      }

      'absent': {
        exec { "a2dismod ${name}":
          command => "${commands_path}/a2dismod ${name}",
          onlyif  => "/bin/sh -c '[ -L ${apache_c2c::params::conf}/mods-enabled/${name}.load ] \\
            || [ -e ${apache_c2c::params::conf}/mods-enabled/${name}.load ]'",
          require => $a2enmod_deps,
          notify  => Service['httpd'],
        }
      }

      default: {
        fail ( "Unknown ensure value: '${ensure}'" )
      }
    }
  }

}
