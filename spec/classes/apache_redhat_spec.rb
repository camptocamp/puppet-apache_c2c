require 'spec_helper'

describe 'apache_c2c::redhat' do
  let(:pre_condition) { "include ::apache_c2c" }

  on_supported_os.select { |os| os =~ /redhat/ }.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      let(:conf) { '/etc/httpd' }
      let(:conf_seltype) { 'httpd_config_t' }

      it { should contain_class('apache_c2c::params') }

      ['a2ensite', 'a2dissite', 'a2enmod', 'a2dismod'].each do |script|
        it { should contain_file("/usr/local/sbin/#{script}").with(
          {
            'ensure' => 'file',
            'mode'   => '0755',
            'owner'  => 'root',
            'group'  => 'root',
            'source' => 'puppet:///modules/apache_c2c/usr/local/sbin/a2X.redhat'
          }
        ) }
      end

      it { should contain_augeas('select httpd mpm httpd').with_changes('set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/httpd') }

      ['sites-available', 'sites-enabled', 'mods-enabled'].each do |dir|
        it { should contain_file("#{conf}/#{dir}").with(
          {
            'ensure'  => 'directory',
            'mode'    => '0755',
            'owner'   => 'root',
            'group'   => 'root',
            'seltype' => conf_seltype,
          }
        ) }
      end

      it { should contain_file("#{conf}/conf/httpd.conf").with(
        {
          'ensure'  => 'file',
          'seltype' => conf_seltype,
        }
      ) }

      it { should contain_file("#{conf}/mods-available").with(
        {
          'ensure'  => 'directory',
          'source'  => "puppet:///modules/apache_c2c/etc/httpd/mods-available/redhat#{facts[:operatingsystemmajrelease]}/",
          'recurse' => 'true',
          'mode'    => '0755',
          'owner'   => 'root',
          'group'   => 'root',
          'seltype' => conf_seltype,
        }
      ) }

      it { should contain_apache_c2c__module('log_config').with_ensure('present') }

      it { should contain_file('/var/www/cgi-bin').with_ensure('absent') }

      it { should contain_file("#{conf}/conf.d/proxy_ajp.conf").with_ensure('file').with_content(/# File managed by puppet/) }
    end
  end
end
