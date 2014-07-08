# about $allowfullyearview, refer to templates/awstats.erb in this module for
# a detailed explanation an possible values.
define apache_c2c::aw-stats($ensure=present, $aliases=[], $allowfullyearview=2) {

  # used in ERB template
  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  file { "/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    content => template('apache_c2c/awstats.erb'),
    require => [Package['apache'], Class['apache_c2c::awstats']],
  }

  $source = $::osfamily ? {
    RedHat => 'puppet:///modules/apache_c2c/awstats.rh.conf',
    Debian => 'puppet:///modules/apache_c2c/awstats.deb.conf',
  }
  $seltype = $::osfamily ? {
    'RedHat' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => $source,
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
    require => Apache_c2c::Vhost[$name],
  }
}
