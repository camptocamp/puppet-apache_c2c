class apache::security {

  case $::operatingsystem {

    RedHat,CentOS: {
      package { "mod_security":
        ensure => present,
        alias => "apache-mod_security",
      }

      file { "/etc/httpd/conf.d/mod_security.conf":
        ensure  => present,
        content => "# file managed by puppet

<IfModule mod_security2.c>
  Include modsecurity.d/modsecurity_localrules.conf
</IfModule>
",
        require => Package["mod_security"],
        notify  => Exec["apache-graceful"],
      }
    }

    Debian: {
      package { "libapache-mod-security":
        ensure => present,
        alias => "apache-mod_security",
      }
    }
  }

  apache::module { ["unique_id", "security"]:
    ensure => present,
    require => Package["apache-mod_security"],
  }

}
