# == Definition: apache::vhost-ssl
#
# This definition is deprecated and was replaced
# by apache::vhost::ssl.
#
# The definition now wraps around apache::vhost::ssl
# for backward compatibility reasons.

define apache::vhost-ssl (
  $ensure=present,
  $config_file='',
  $config_content=false,
  $htdocs=false,
  $conf=false,
  $readme=false,
  $docroot=false,
  $cgibin=true,
  $user='',
  $admin=$::admin,
  $group='',
  $mode=2570,
  $aliases=[],
  $ip_address='*',
  $cert=false,
  $certkey=false,
  $cacert=false,
  $cacrl=false,
  $certchain=false,
  $certcn=false,
  $verifyclient=undef,
  $options=[],
  $days='3650',
  $publish_csr=false,
  $sslonly=false,
  $ports=['*:80'],
  $sslports=['*:443'],
  $accesslog_format='combined',
) {

  fail 'apache::vhost-ssl is deprecated. Use apache::vhost::ssl instead'

}
