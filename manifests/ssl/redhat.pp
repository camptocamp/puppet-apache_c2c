class apache::ssl::redhat inherits apache::base::ssl {

  package {'mod_ssl':
    ensure => installed,
  }

  file {'/etc/httpd/conf.d/ssl.conf':
    ensure  => present,
    content => "# File managed by puppet
#
# This file is installed by the 'mod_ssl' RedHat package but we put this
# configuration in mods-available/ssl.load instead. We must keep this file
# here to avoid it being recreated on package upgrade.
",
    require => Package['mod_ssl'],
    notify  => Service['apache'],
    before  => Exec['apache-graceful'],
  }

  apache::module { 'ssl':
    ensure  => present,
    require => File['/etc/httpd/conf.d/ssl.conf'],
    notify  => Service['apache'],
    before  => Exec['apache-graceful'],
  }

  case $::lsbmajdistrelease {
    5,6: {
      file {'/etc/httpd/mods-available/ssl.load':
        ensure  => present,
        content => template("apache/ssl.load.rhel${::lsbmajdistrelease}.erb"),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        seltype => 'httpd_config_t',
        require => File['/etc/httpd/mods-available'],
      }
    }
  }
}
