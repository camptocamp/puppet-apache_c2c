require 'spec_helper'

describe 'apache_c2c::base' do

  let(:pre_condition) {
    "include ::apache_c2c::ssl"
  }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/foo',
        })
      end

      case facts[:osfamily]
      when 'Debian'
        let(:conf) { '/etc/apache2' }
        let(:group) { 'www-data' }
        let(:log) { '/var/log/apache2' }
        let(:pkg) { 'apache2' }
        let(:root) { '/var/www' }
        let(:user) { 'www-data' }
      when 'RedHat'
        let(:conf) { '/etc/httpd' }
        let(:group) { 'apache' }
        let(:log) { '/var/log/httpd' }
        let(:pkg) { 'httpd' }
        let(:root) { '/var/www/vhosts' }
        let(:user) { 'apache' }
      end

      context 'without default vhosts' do
        let(:pre_condition) { "class { '::apache_c2c': default_vhost => false, }" }

        it { should contain_file("#{conf}/sites-enabled/000-default-vhost").with_ensure('absent') }
      end

      context 'without parameters' do
        let(:pre_condition) { "include ::apache_c2c" }
        it { should contain_class('apache_c2c::params') }

        it { should contain_class('concat::setup') }

        it { should contain_concat("#{conf}/ports.conf") }

        it do should contain_file('log directory').with(
          'path'   => log,
          'ensure' => 'directory',
          'mode'   => '0755',
          'owner'  => 'root',
          'group'  => 'root'
        ) end

        it do should contain_user('apache user').with(
          'name'   => user,
          'ensure' => 'present',
          'shell'  => '/bin/sh'
        ) end

        it do should contain_group('apache group').with(
          'name'   => group,
          'ensure' => 'present'
        ) end

        it do should contain_package('httpd').with(
          'name'   => pkg,
          'ensure' => 'installed'
        ) end

        it do should contain_service('httpd').with(
          'name'       => pkg,
          'ensure'     => 'running',
          'enable'     => 'true',
          'hasrestart' => 'true'
        ) end

        it do should contain_file('logrotate configuration').with(
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'source' => nil
        ) end

        it { should contain_apache_c2c__listen('80').with_ensure('present') }
        it { should contain_apache_c2c__namevhost('*:80').with_ensure('present') }

        ['alias', 'auth_basic', 'authn_file', 'authz_default', 'authz_groupfile', 'authz_host', 'authz_user', 'autoindex', 'dir', 'env', 'mime', 'negotiation', 'rewrite', 'setenvif', 'status', 'cgi'].each do |m|
          it { should contain_apache_c2c__module(m).with_ensure('present') }
        end

        case facts[:osfamily]
        when 'Debian'
          it do should contain_file('default status module configuration').with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'source' => 'puppet:///modules/apache_c2c/etc/apache2/mods-available/status.conf'
          ) end
          it do should contain_exec('apache-graceful').with(
            'command'     => 'apache2ctl graceful',
            'refreshonly' => 'true',
            'onlyif'      => nil
          ) end
        when 'RedHat'
          it do should contain_file('default status module configuration').with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'source' => 'puppet:///modules/apache_c2c/etc/httpd/conf/status.conf'
          ) end
          it do should contain_exec('apache-graceful').with(
            'command'     => 'apachectl graceful',
            'refreshonly' => 'true',
            'onlyif'      => nil
          ) end
        end

        it do should contain_file('default virtualhost').with(
          'path'   => "#{conf}/sites-available/default-vhost",
          'ensure' => 'file',
          'mode'   => '0644'
        ) end

        # No disable default vhost
        it do should contain_file("#{conf}/sites-enabled/000-default-vhost").with(
          'ensure' => 'link',
          'target' => "#{conf}/sites-available/default-vhost"
        ) end

        it do should contain_file('/usr/local/bin/htgroup').with(
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
          'source' => 'puppet:///modules/apache_c2c/usr/local/bin/htgroup'
        ) end

        ['default', '000-default', 'default-ssl'].each do |s|
          it { should contain_file("#{conf}/sites-enabled/#{s}").with_ensure('absent') }
        end

      end
    end
  end
end
