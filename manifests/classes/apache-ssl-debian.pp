class apache::ssl::debian inherits apache::base::ssl {

  apache::module {"ssl":
    ensure => present,
  }

  if !defined(Package["ca-certificates"]) {
    package { "ca-certificates":
      ensure => present,
    }
  }
}
