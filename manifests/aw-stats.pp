# about $allowfullyearview, refer to templates/awstats.erb in this module for
# a detailed explanation an possible values.
define apache::aw-stats($ensure=present, $aliases=[], $allowfullyearview=2) {

  # used in ERB template
  $wwwroot = $apache::root
  validate_absolute_path($wwwroot)

  file { "/etc/awstats/awstats.${name}.conf":
    ensure  => $ensure,
    content => template('apache/awstats.erb'),
    require => [Package['apache'], Class['apache::awstats']],
  }

  $source = $::operatingsystem ? {
    /RedHat|CentOS/ => "puppet:///modules/${module_name}/awstats.rh.conf",
    /Debian|Ubuntu/ => "puppet:///modules/${module_name}/awstats.deb.conf",
  }
  $seltype = $::operatingsystem ? {
    'RedHat' => 'httpd_config_t',
    'CentOS' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${name}/conf/awstats.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    source  => $source,
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
    require => Apache::Vhost[$name],
  }
}
