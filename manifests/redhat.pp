class apache_c2c::redhat inherits apache_c2c::base {

  include ::apache_c2c::params
  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  # BEGIN inheritance from apache::base
  Exec['apache-graceful'] {
    command => 'apachectl graceful',
  }

  # the following variables are used in template logrotate-httpd.erb
  $logrotate_paths = "${wwwroot}/*/logs/*.log ${apache_c2c::params::log}/*log"
  $httpd_pid_file = $::operatingsystemmajrelease ? {
    /4|5/   => '/var/run/httpd.pid',
    default => '/var/run/httpd/httpd.pid',
  }
  $httpd_reload_cmd = '/sbin/service httpd reload > /dev/null 2> /dev/null || true'
  $awstats_condition = '-x /etc/cron.hourly/awstats'
  $awstats_command = '/etc/cron.hourly/awstats || true'
  File['logrotate configuration'] {
    path    => '/etc/logrotate.d/httpd',
    content => template('apache_c2c/logrotate-httpd.erb'),
  }

  if $::apache_c2c::backend != 'puppetlabs' {
    Package['httpd'] {
      require => [
        File['/usr/local/sbin/a2ensite'],
        File['/usr/local/sbin/a2dissite'],
        File['/usr/local/sbin/a2enmod'],
        File['/usr/local/sbin/a2dismod']
        ],
    }

    File['default status module configuration'] {
      path   => "${apache_c2c::params::conf}/conf.d/status.conf",
      source => 'puppet:///modules/apache_c2c/etc/httpd/conf/status.conf',
    }
  }

  File['default virtualhost'] {
    seltype => 'httpd_config_t',
  }
  # END inheritance from apache::base

  file {[
    '/usr/local/sbin/a2ensite',
    '/usr/local/sbin/a2dissite',
    '/usr/local/sbin/a2enmod',
    '/usr/local/sbin/a2dismod',
  ]:
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => file('apache_c2c/usr/local/sbin/a2X.redhat'),
  }

  $httpd_mpm = 'httpd'

  augeas { "select httpd mpm ${httpd_mpm}":
    changes => "set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/${httpd_mpm}",
    require => Package['httpd'],
    notify  => Service['httpd'],
  }

  file { [
      "${apache_c2c::params::conf}/sites-available",
      "${apache_c2c::params::conf}/sites-enabled",
      "${apache_c2c::params::conf}/mods-enabled",
    ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['httpd'],
  }

  if $::apache_c2c::backend != 'puppetlabs' {
    file { "${apache_c2c::params::conf}/conf/httpd.conf":
      ensure  => file,
      content => template('apache_c2c/httpd.conf.erb'),
      seltype => 'httpd_config_t',
      notify  => Service['httpd'],
      require => Package['httpd'],
    }
  }

  # the following command was used to generate the content of the directory:
  # egrep '(^|#)LoadModule' /etc/httpd/conf/httpd.conf | sed -r 's|\
  # #?(.+ (.+)_module .+)|echo "\1" > mods-available/redhat5/\2.load|' | sh
  # ssl.load was then changed to a template (see apache-ssl-redhat.pp)
  $source = $::operatingsystemmajrelease ? {
    '5' => 'puppet:///modules/apache_c2c/etc/httpd/mods-available/redhat5/',
    '6' => 'puppet:///modules/apache_c2c/etc/httpd/mods-available/redhat6/',
  }
  file { "${apache_c2c::params::conf}/mods-available":
    ensure  => directory,
    source  => $source,
    recurse => true,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    seltype => 'httpd_config_t',
    require => Package['httpd'],
  }

  if $::apache_c2c::backend != 'puppetlabs' {
    # this module is statically compiled on debian and must be enabled here
    apache_c2c::module {'log_config':
      ensure => present,
      notify => Exec['apache-graceful'],
    }
  }

  # it makes no sens to put CGI here, deleted from the default vhost config
  file {'/var/www/cgi-bin':
    ensure  => absent,
    force   => true,
    require => Package['httpd'],
  }

  # no idea why redhat choose to put this file there. apache fails if it's
  # present and mod_proxy isn't...
  file { "${apache_c2c::params::conf}/conf.d/proxy_ajp.conf":
    ensure  => file,
    content => "# File managed by puppet
#
# This file is installed by 'httpd' RedHat package but we're not using it. We
# must keep it here to avoid it being recreated on package upgrade.
",
    require => Package['httpd'],
    notify  => Exec['apache-graceful'],
  }

}

