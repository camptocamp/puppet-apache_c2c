class apache::ssl::debian inherits apache::debian {

  apache::module {"ssl":
    ensure => present,
  }

  File ["/etc/apache2/ports.conf"] {
    content => "ServerName 127.0.1.1\nListen 80\nListen 443\n",
  }

}
