require 'spec_helper'

describe 'apache::base' do
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      it { should include_class('concat::setup') }

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

      it { should contain_apache__listen('80').with_ensure('present') }
      it { should contain_apache__namevhost('*:80').with_ensure('present') }

      MODULES.each do |m|
        it { should contain_apache__module(m).with_ensure('present') }
      end

      it do should contain_file('default status module configuration').with(
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'source' => nil
      ) end

      it do should contain_file('default virtualhost').with(
        'path'   => "#{VARS[os]['conf']}/sites-available/default-vhost",
        'ensure' => 'present',
        'mode'   => '0644'
      ) end


      describe 'When disable default vhost' do
        let(:facts) { {
          :operatingsystem              => os,
          :apache_disable_default_vhost => 'true'
        } }

        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/000-default-vhost").with_ensure('absent') }
      end

      # No disable default vhost
      it do should contain_file("#{VARS[os]['conf']}/sites-enabled/000-default-vhost").with(
        'ensure' => 'link',
        'target' => "#{VARS[os]['conf']}/sites-available/default-vhost"
      ) end

      it do should contain_exec('apache-graceful').with(
        'command'     => 'apache-graceful',
        'refreshonly' => 'true',
        'onlyif'      => nil
      ) end

      it do should contain_file('/usr/local/bin/htgroup').with(
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
        'source' => 'puppet:///modules/apache/usr/local/bin/htgroup'
      ) end

      ['default', '000-default', 'default-ssl'].each do |s|
        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/#{s}").with_ensure('absent') }
      end

    end
  end
end
