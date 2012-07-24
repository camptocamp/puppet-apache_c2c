module SpecParams
end

OSES = ['Debian', 'RedHat', 'Ubuntu', 'CentOS']

require 'puppet'
PUPPETVERSION = Puppet::PUPPETVERSION.to_s

VARS = {
  'Debian' => {
    'pkg'            => 'apache2',
    'root'           => '/var/www',
    'user'           => 'www-data',
    'group'          => 'www-data',
    'conf'           => '/etc/apache2',
    'log'            => '/var/log/apache2',
    'access_log'     => '/var/log/apache2/access.log',
    'a2ensite'       => '/usr/sbin/a2ensite',
    'a2dissite'      => '/usr/sbin/a2dissite',
    'error_log'      => '/var/log/apache2/error.log',
    'sudo'           => '/usr/sbin/apache2ctl',
    'awstats_tmpl'   => 'puppet:///modules/apache/awstats.deb.conf',
    'conf_seltype'   => nil,
    'cont_seltype'   => nil,
    'script_seltype' => nil,
    'log_seltype'    => nil,
    'apache_devel'   => 'apache2-threaded-dev',
    'a2enmod'        => '/usr/sbin/a2enmod',
    'a2dismod'       => '/usr/sbin/a2dismod',
    'mod_security'   => 'libapache-mod-security',
    'mod_svn'        => 'libapache2-svn',
  },

  'RedHat'           => {
    'pkg'            => 'httpd',
    'root'           => '/var/www/vhosts',
    'user'           => 'apache',
    'group'          => 'apache',
    'conf'           => '/etc/httpd',
    'log'            => '/var/log/httpd',
    'access_log'     => '/var/log/httpd/access.log',
    'a2ensite'       => '/usr/local/sbin/a2ensite',
    'a2dissite'      => '/usr/local/sbin/a2dissite',
    'error_log'      => '/var/log/httpd/error.log',
    'sudo'           => '/usr/sbin/apachectl, /sbin/service apache2',
    'awstats_tmpl'   => 'puppet:///modules/apache/awstats.rh.conf',
    'conf_seltype'   => 'httpd_config_t',
    'cont_seltype'   => 'httpd_sys_content_t',
    'script_seltype' => 'httpd_sys_script_exec_t',
    'log_seltype'    => 'httpd_log_t',
    'apache_devel'   => 'httpd-devel',
    'a2enmod'        => '/usr/local/sbin/a2enmod',
    'a2dismod'       => '/usr/local/sbin/a2dismod',
    'mod_security'   => 'mod_security',
    'mod_svn'        => 'mod_dav_svn',
  },
}
VARS['Ubuntu'] = VARS['Debian']
VARS['CentOS'] = VARS['RedHat']

MODULES = ['alias', 'auth_basic', 'authn_file', 'authz_default', 'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env', 'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'cgi']

REVERSEPROXY_MODULES = ['proxy', 'proxy_http', 'proxy_ajp', 'proxy_connect']
