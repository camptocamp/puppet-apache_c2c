class apache::redhat inherits apache::base {

  include apache::params

  # BEGIN inheritance from apache::base
  Exec['apache-graceful'] {
    command => 'apachectl graceful',
    onlyif  => 'apachectl configtest',
  }

  Package['apache'] {
    require => [
      File['/usr/local/sbin/a2ensite'],
      File['/usr/local/sbin/a2dissite'],
      File['/usr/local/sbin/a2enmod'],
      File['/usr/local/sbin/a2dismod']
      ],
  }

  # the following variables are used in template logrotate-httpd.erb
  $logrotate_paths = "${apache::params::root}/*/logs/*.log ${apache::params::log}/*log"
  $httpd_pid_file = $::lsbmajdistrelease ? {
    /4|5/   => '/var/run/httpd.pid',
    default => '/var/run/httpd/httpd.pid',
  }
  $httpd_reload_cmd = '/sbin/service httpd reload > /dev/null 2> /dev/null || true'
  $awstats_condition = '-x /etc/cron.hourly/awstats'
  $awstats_command = '/etc/cron.hourly/awstats || true'
  File['logrotate configuration'] {
    path    => '/etc/logrotate.d/httpd',
    content => template('apache/logrotate-httpd.erb'),
  }

  File['default status module configuration'] {
    path   => "${apache::params::conf}/conf.d/status.conf",
    source => "puppet:///modules/${module_name}/etc/httpd/conf/status.conf",
  }

  File['default virtualhost'] {
    seltype => 'httpd_config_t',
  }
  # END inheritance from apache::base

  file {[
    '/usr/local/sbin/a2ensite',
    '/usr/local/sbin/a2dissite',
    '/usr/local/sbin/a2enmod',
    '/usr/local/sbin/a2dismod'
  ]:
    ensure => present,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/${module_name}/usr/local/sbin/a2X.redhat",
  }

  $httpd_mpm = $apache_mpm_type ? {
    ''         => 'httpd', # default MPM
    'pre-fork' => 'httpd',
    'prefork'  => 'httpd',
    default    => "httpd.${apache_mpm_type}",
  }

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/${httpd_mpm}",
    require => Package['apache'],
    notify  => Service['apache'],
  }

  file { [
      "${apache::params::conf}/sites-available",
      "${apache::params::conf}/sites-enabled",
      "${apache::params::conf}/mods-enabled"
    ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['apache'],
  }

  file { "${apache::params::conf}/conf/httpd.conf":
    ensure  => present,
    content => template('apache/httpd.conf.erb'),
    seltype => 'httpd_config_t',
    notify  => Service['apache'],
    require => Package['apache'],
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|#?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  file { "${apache::params::conf}/mods-available":
    ensure  => directory,
    source  => $::lsbmajdistrelease ? {
      5 => "puppet:///modules/${module_name}/etc/httpd/mods-available/redhat5/",
      6 => "puppet:///modules/${module_name}/etc/httpd/mods-available/redhat6/",
    },
    recurse => true,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['apache'],
  }

  # this module is statically compiled on debian and must be enabled here
  apache::module {'log_config':
    ensure => present,
    notify => Exec['apache-graceful'],
  }

  # it makes no sens to put CGI here, deleted from the default vhost config
  file {'/var/www/cgi-bin':
    ensure  => absent,
    force   => true,
    require => Package['apache'],
  }

  # no idea why redhat choose to put this file there. apache fails if it's
  # present and mod_proxy isn't...
  file { "${apache::params::conf}/conf.d/proxy_ajp.conf":
    ensure  => present,
    content => "# File managed by puppet
#
# This file is installed by 'httpd' RedHat package but we're not using it. We
# must keep it here to avoid it being recreated on package upgrade.
",
    require => Package['apache'],
    notify  => Exec['apache-graceful'],
  }

}

