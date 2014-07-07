require 'spec_helper'

describe 'apache_c2c::base' do

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir    => '/foo',
        :lsbmajdistrelease => '6',
        :operatingsystem   => os,
        :osfamily          => os,
      } }

      context 'without default vhosts' do
        let(:pre_condition) { "class { '::apache_c2c': default_vhost => false, }" }

        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/000-default-vhost").with_ensure('absent') }
      end

      context 'without parameters' do
        let(:pre_condition) { "include ::apache_c2c" }
        it { should contain_class('apache_c2c::params') }

        it { should contain_class('concat::setup') }

        it { should contain_concat("#{VARS[os]['conf']}/ports.conf") }

        it do should contain_file('root directory').with(
          'path'   => VARS[os]['root'],
          'ensure' => 'directory',
          'mode'   => '0755',
          'owner'  => 'root',
          'group'  => 'root'
        ) end

        it do should contain_file('log directory').with(
          'path'   => VARS[os]['log'],
          'ensure' => 'directory',
          'mode'   => '0755',
          'owner'  => 'root',
          'group'  => 'root'
        ) end

        it do should contain_user('apache user').with(
          'name'   => VARS[os]['user'],
          'ensure' => 'present',
          'shell'  => '/bin/sh'
        ) end

        it do should contain_group('apache group').with(
          'name'   => VARS[os]['group'],
          'ensure' => 'present'
        ) end

        it do should contain_package('apache').with(
          'name'   => VARS[os]['pkg'],
          'ensure' => 'installed'
        ) end

        it do should contain_service('apache').with(
          'name'       => VARS[os]['pkg'],
          'ensure'     => 'running',
          'enable'     => 'true',
          'hasrestart' => 'true'
        ) end

        it do should contain_file('logrotate configuration').with(
          'ensure' => 'present',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'source' => nil
        ) end

        it { should contain_apache_c2c__listen('80').with_ensure('present') }
        it { should contain_apache_c2c__namevhost('*:80').with_ensure('present') }

        MODULES.each do |m|
          it { should contain_apache_c2c__module(m).with_ensure('present') }
        end

        if os == 'Debian'
          it do should contain_file('default status module configuration').with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'source' => 'puppet:///modules/apache_c2c/etc/apache2/mods-available/status.conf'
          ) end
        elsif os == 'RedHat'
          it do should contain_file('default status module configuration').with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'source' => 'puppet:///modules/apache_c2c/etc/httpd/conf/status.conf'
          ) end
        end

        it do should contain_file('default virtualhost').with(
          'path'   => "#{VARS[os]['conf']}/sites-available/default-vhost",
          'ensure' => 'present',
          'mode'   => '0644'
        ) end

        # No disable default vhost
        it do should contain_file("#{VARS[os]['conf']}/sites-enabled/000-default-vhost").with(
          'ensure' => 'link',
          'target' => "#{VARS[os]['conf']}/sites-available/default-vhost"
        ) end

        if os == 'Debian'
          it do should contain_exec('apache-graceful').with(
            'command'     => 'apache2ctl graceful',
            'refreshonly' => 'true',
            'onlyif'      => nil
          ) end
        elsif os == 'RedHat'
          it do should contain_exec('apache-graceful').with(
            'command'     => 'apachectl graceful',
            'refreshonly' => 'true',
            'onlyif'      => nil
          ) end
        end

        it do should contain_file('/usr/local/bin/htgroup').with(
          'ensure' => 'present',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
          'source' => 'puppet:///modules/apache_c2c/usr/local/bin/htgroup'
        ) end

        ['default', '000-default', 'default-ssl'].each do |s|
          it { should contain_file("#{VARS[os]['conf']}/sites-enabled/#{s}").with_ensure('absent') }
        end

      end
    end
  end
end
