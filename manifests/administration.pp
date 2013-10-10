class apache_c2c::administration (
  $sudo_user = $sudo_apache_admin_user,
) {

  include ::apache_c2c::params

  $distro_specific_apache_sudo = $::osfamily ? {
    'RedHat' => "/usr/sbin/apachectl, /sbin/service ${apache_c2c::params::pkg}",
    'Debian' => '/usr/sbin/apache2ctl',
  }

  group { 'apache-admin':
    ensure => present,
    system => true,
  }

  # used in erb template
  $wwwpkgname = $apache_c2c::params::pkg
  $wwwuser    = $apache_c2c::params::user

  $sudo_group = '%apache-admin'
  $sudo_user_alias = flatten([$sudo_group, $sudo_user])
  $sudo_cmnd = "/etc/init.d/${wwwpkgname}, /bin/su ${wwwuser}, /bin/su - ${wwwuser}, ${distro_specific_apache_sudo}"

  sudo::directive { 'apache-administration':
    ensure  => present,
    content => template("${module_name}/sudoers.apache.erb"),
    require => Group['apache-admin'],
  }

}
