class apache_c2c::ssl::debian inherits apache_c2c::base::ssl {

  if $::apache_c2c::backend != 'puppetlabs' {
    apache_c2c::module {'ssl':
      ensure => present,
    }
    augeas {'disable SSLv3 cipher':
      incl    => '/etc/apache2/mods-available/ssl.conf',
      lens    => 'Httpd.lns',
      changes => ["set IfModule/*[self::directive='SSLProtocol']/arg[last()+1] -SSLv3"],
      onlyif  => "match IfModule/*[self::directive='SSLProtocol']/arg not_include '-SSLv3'",
      require => Package['httpd'],
      notify  => Service['httpd'],
    }
  }

  if !defined(Package['ca-certificates']) {
    package { 'ca-certificates':
      ensure => present,
    }
  }
}
