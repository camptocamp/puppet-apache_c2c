# == Definition: apache::vhost::ssl
#
# Creates an SSL enabled virtualhost.
#
# As it calls apache::vhost, most of the parameters are the same. A few
# additional parameters are used to configure the SSL specific stuff.
#
# Parameters:
# - *$name*: the name of the virtualhost. Will be used as the CN in the
#   generated ssl certificate.
# - *$ensure*: see apache::vhost
# - *$config_file*: see apache::vhost
# - *$config_content*: see apache::vhost
# - *$readme*: see apache::vhost
# - *$docroot*: see apache::vhost
# - *$cgibin*: see apache::vhost
# - *$user*: see apache::vhost
# - *$admin*: see apache::vhost
# - *$group*: see apache::vhost
# - *$mode*: see apache::vhost
# - *$aliases*: see apache::vhost. The generated SSL certificate will have this
#   list as DNS subjectAltName entries.
# - *$ip_address*: the ip address defined in the <VirtualHost> directive.
#   Defaults to "*".
# - *$verifyclient*: set the Certificate verification level for the Client
#   Authentication. Must be one of 'none', 'optional', 'require' or
#   'optional_no_ca'.
# - *$options*: Configure various SSL engine run-time options.
# - *$sslonly*: if set to "true", only the https virtualhost will be configured.
#   Defaults to "true", which means there is a redirection from non-SSL port to
#   SSL
# - *ports*: array specifying the ports on which the non-SSL vhost will be
#   reachable. Defaults to "*:80".
# - *sslports*: array specifying the ports on which the SSL vhost will be
#   reachable. Defaults to "*:443".
# - *accesslog_format*: format string for access logs. Defaults to "combined".
#
# Requires:
# - Class["apache-ssl"]
#
# Example usage:
#
#   include apache_c2c::ssl
#
#   apache_c2c::vhost::ssl { "foo.example.com":
#     ensure      => present,
#     ip_address  => "10.0.0.2",
#   }
#
#   apache_c2c::vhost::ssl { "bar.example.com":
#     ensure      => present,
#     ip_address  => "10.0.0.3",
#     cert        => "puppet:///modules/exampleproject/ssl-certs/bar.example.com.crt",
#     certchain   => "puppet:///modules/exampleproject/ssl-certs/quovadis.chain.crt",
#     sslonly     => true,
#   }

define apache_c2c::vhost::ssl (
  $ensure               = present,
  $servername           = $name,
  $config_file          = undef,
  # lint:ignore:empty_string_assignment
  $user                 = '',
  $group                = '',
  # lint:endignore
  $config_content       = false,
  $readme               = false,
  $docroot              = false,
  $cgibin               = true,
  $admin                = undef,
  $mode                 = '2570',
  $aliases              = [],
  $ip_address           = '*',
  $ssl_cert             = undef,
  $ssl_key              = undef,
  $ssl_chain            = undef,
  $ssl_ca               = $::osfamily ? {
    'RedHat' => '/etc/pki/tls/certs/ca-bundle.crt',
    'Debian' => '/etc/ssl/certs/ca-certificates.crt',
  },
  $ssl_crl              = undef,
  $verifyclient         = undef,
  $options              = [],
  $sslonly              = true,
  $ports                = ['*:80'],
  $sslports             = ['*:443'],
  $accesslog_format     = undef,
) {

  # Validate parameters
  if ($verifyclient != undef) {
    validate_re(
      $verifyclient,
      '(none|optional|require|optional_no_ca)',
      'verifyclient must be one of none, optional, require or optional_no_ca'
    )
  }
  validate_array($options)

  include ::apache_c2c::params

  $wwwuser = $user ? {
    ''      => $apache_c2c::params::user,
    default => $user,
  }

  $wwwgroup = $group ? {
    ''      => $apache_c2c::params::group,
    default => $group,
  }

  # used in ERB templates
  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  $documentroot = $docroot ? {
    false   => "${wwwroot}/${name}/htdocs",
    default => $docroot,
  }

  $cgipath = $cgibin ? {
    true    => "${wwwroot}/${name}/cgi-bin/",
    false   => false,
    default => $cgibin,
  }

  # Set access log format
  if $accesslog_format {
    $_accesslog_format = "\"${accesslog_format}\""
  } else {
    $_accesslog_format = 'combined'
  }

  # call parent definition to actually do the virtualhost setup.
  if $config_content {
    $_config_content     = $config_content

    $access_log          = undef
    $additional_includes = undef
    $directories         = undef
    $error_log           = undef
    $log_level           = undef
    $rewrites            = undef
    $scriptaliases       = undef
  } else {
    if $sslonly {
      $sslport = split($sslports[0], ':')
      $_config_content     = template('apache_c2c/vhost-redirect-ssl.erb')

      $access_log          = false
      $additional_includes = []
      $directories         = [{}]
      $error_log           = false
      $log_level           = false
      $rewrites            = [
        {
          rewrite_rule => "/(.*) https://%{HTTP_HOST}:${sslport[1]}/\$1 [R=302,NE]",
        },
      ]
      $scriptaliases       = []
    } else {
      $_config_content     = template('apache_c2c/vhost.erb')

      $access_log          = undef
      $additional_includes = undef
      $directories         = undef
      $error_log           = undef
      $log_level           = undef
      $rewrites            = undef
      $scriptaliases       = undef
    }
  }
  apache_c2c::vhost { $name:
    ensure              => $ensure,
    config_file         => $config_file,
    config_content      => $_config_content,
    aliases             => $aliases,
    readme              => $readme,
    docroot             => $docroot,
    user                => $wwwuser,
    admin               => $admin,
    group               => $wwwgroup,
    mode                => $mode,
    ports               => $ports,
    accesslog_format    => $accesslog_format,

    access_log          => $access_log,
    additional_includes => $additional_includes,
    directories         => $directories,
    error_log           => $error_log,
    log_level           => $log_level,
    rewrites            => $rewrites,
    scriptaliases       => $scriptaliases,
  }
  if ! ( $config_content or $config_file) {
    apache_c2c::vhost { "${name}-ssl":
      ensure           => $ensure,
      accesslog_format => $accesslog_format,
      admin            => $admin,
      aliases          => $aliases,
      config_content   => template('apache_c2c/vhost-ssl.erb'),
      config_file      => $config_file,
      docroot          => $docroot,
      group            => $wwwgroup,
      mode             => $mode,
      ports            => $sslports,
      readme           => $readme,
      user             => $wwwuser,
      servername       => $name,

      ssl              => true,
      ssl_ca           => $ssl_ca,
      ssl_cert         => $ssl_cert,
      ssl_certs_dir    => false,
      ssl_chain        => $ssl_chain,
      ssl_key          => $ssl_key,
    }
  }

  if $ensure == 'present' {
    file { "${wwwroot}/${name}/ssl":
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      seltype => 'cert_t',
      require => [File["${wwwroot}/${name}"]],
    }
  }
}
