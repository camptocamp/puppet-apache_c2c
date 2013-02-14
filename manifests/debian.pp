class apache::debian inherits apache::base {

  include apache::params

  # BEGIN inheritance from apache::base
  Exec["apache-graceful"] {
    command => "apache2ctl graceful",
    onlyif => "apache2ctl configtest",
  }

  # the following variables are used in template logrotate-httpd.erb
  $logrotate_paths = "${apache::params::root}/*/logs/*.log ${apache::params::log}/*log"
  $httpd_pid_file = "/var/run/apache2.pid"
  $httpd_reload_cmd = "/etc/init.d/apache2 restart > /dev/null"
  $awstats_condition = "-f /usr/share/doc/awstats/examples/awstats_updateall.pl -a -f /usr/lib/cgi-bin/awstats.pl"
  $awstats_command = "/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null"
  File["logrotate configuration"] {
    path    => "/etc/logrotate.d/apache2",
    content => template("${module_name}/logrotate-httpd.erb"),
  }

  File["default status module configuration"] {
    path => "${apache::params::conf}/mods-available/status.conf",
    source => "puppet:///modules/${module_name}/etc/apache2/mods-available/status.conf",
  }
  # END inheritance from apache::base

  $mpm_package = $apache_mpm_type ? {
    "" => "apache2-mpm-prefork",
    default => "apache2-mpm-${apache_mpm_type}",
  }

  package { "${mpm_package}":
    ensure  => installed,
    require => Package["apache"],
  }

  # directory not present in lenny
  file { "${apache::params::root}/apache2-default":
    ensure => absent,
    force  => true,
  }

  file { "${apache::params::root}/index.html":
    ensure => absent,
  }

  file { "${apache::params::root}/html/index.html":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => "<html><body><h1>It works!</h1></body></html>\n",
  }

  file { "${apache::params::conf}/conf.d/servername.conf":
    content => "ServerName ${::fqdn}\n",
    notify  => Service["apache"],
    require => Package["apache"],
  }

}
