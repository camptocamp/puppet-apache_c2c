class apache_c2c::ssl::redhat inherits apache_c2c::base::ssl {

  package {'mod_ssl':
    ensure => installed,
  }

  if $::apache_c2c::backend != 'puppetlabs' {
    file {'/etc/httpd/conf.d/ssl.conf':
      ensure  => present,
      content => "# File managed by puppet
      #
      # This file is installed by the 'mod_ssl' RedHat package but we put this
      # configuration in mods-available/ssl.load instead. We must keep this file
      # here to avoid it being recreated on package upgrade.
      ",
      require => Package['mod_ssl'],
      notify  => Service['httpd'],
      before  => Exec['apache-graceful'],
    }
  }

  apache_c2c::module { 'ssl':
    ensure  => present,
    require => File['/etc/httpd/conf.d/ssl.conf'],
    notify  => Service['httpd'],
    before  => Exec['apache-graceful'],
  }

  case $::operatingsystemmajrelease {
    5,6: {
      file {'/etc/httpd/mods-available/ssl.load':
        ensure  => present,
        content => template("apache_c2c/ssl.load.rhel${::operatingsystemmajrelease}.erb"),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        seltype => 'httpd_config_t',
        require => File['/etc/httpd/mods-available'],
      }
    }
    default: {}
  }
}
