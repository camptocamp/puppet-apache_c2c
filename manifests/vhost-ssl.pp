/*

== Definition: apache::vhost-ssl

This definition is deprecated and was replaced
by apache::vhost::ssl.

The definition now wraps around apache::vhost::ssl
for backward compatibility reasons.


*/
define apache::vhost-ssl (
  $ensure=present,
  $config_file="",
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=true,
  $user="",
  $admin=$::admin,
  $group="",
  $mode=2570,
  $aliases=[],
  $ip_address="*",
  $cert=false,
  $certkey=false,
  $cacert=false,
  $cacrl=false,
  $certchain=false,
  $certcn=false,
  $days="3650",
  $publish_csr=false,
  $sslonly=false,
  $ports=['*:80'],
  $sslports=['*:443'],
  $accesslog_format="combined"
) {

  warning "apache::vhost-ssl is deprecated. Use apache::vhost::ssl instead"

  apache::vhost::ssl{$name:
    ensure => $ensure,
    config_file => $config_file,
    config_content => $config_content,
    htdocs => $htdocs,
    conf => $conf,
    readme => $readme,
    docroot => $docroot,
    cgibin => $cgibin,
    user => $user,
    admin => $admin,
    group => $group,
    mode => $mode,
    aliases => $aliases,
    ip_address => $ip_address,
    cert => $cert,
    certkey => $certkey,
    cacert => $cacert,
    cacrl => $cacrl,
    certchain => $certchain,
    certcn => $certcn,
    days => $days,
    publish_csr => $publish_csr,
    sslonly => $sslonly,
    ports => $ports,
    sslports => $sslports,
    accesslog_format => $accesslog_format,
  }

}
