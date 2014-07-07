require 'spec_helper'

describe 'apache_c2c::redhat' do
  let(:pre_condition) { "include ::apache_c2c" }
  ['RedHat'].each do |os|
    let(:facts) { {
      :concat_basedir    => '/foo',
      :operatingsystem   => os,
      :osfamily          => os,
      :lsbmajdistrelease => '5',
    } }

    it { should contain_class('apache_c2c::params') }

    ['a2ensite', 'a2dissite', 'a2enmod', 'a2dismod'].each do |script|
      it { should contain_file("/usr/local/sbin/#{script}").with(
        'ensure' => 'present',
        'mode'   => '0755',
        'owner'  => 'root',
        'group'  => 'root',
        'source' => 'puppet:///modules/apache_c2c/usr/local/sbin/a2X.redhat'
      ) }
    end

    it { should contain_augeas('select httpd mpm httpd').with_changes('set /files/etc/sysconfig/httpd/HTTPD /usr/sbin/httpd') }

    ['sites-available', 'sites-enabled', 'mods-enabled'].each do |dir|
      it { should contain_file("#{VARS[os]['conf']}/#{dir}").with(
        'ensure'  => 'directory',
        'mode'    => '0755',
        'owner'   => 'root',
        'group'   => 'root',
        'seltype' => VARS[os]['conf_seltype']
      ) }
    end

    it { should contain_file("#{VARS[os]['conf']}/conf/httpd.conf").with(
      'ensure'  => 'present',
      'seltype' => VARS[os]['conf_seltype']
    ) }

    ['5', '6'].each do |release|
      describe "with lsbmajdistrelease #{release}" do
        let(:facts) { {
          :concat_basedir    => '/foo',
          :operatingsystem   => os,
          :osfamily          => os,
          :lsbmajdistrelease => release,
        } }

        it { should contain_file("#{VARS[os]['conf']}/mods-available").with(
          'ensure'  => 'directory',
          'source'  => "puppet:///modules/apache_c2c/etc/httpd/mods-available/redhat#{release}/",
          'recurse' => 'true',
          'mode'    => '0755',
          'owner'   => 'root',
          'group'   => 'root',
          'seltype' => VARS[os]['conf_seltype']
        ) }
      end
    end

    it { should contain_apache_c2c__module('log_config').with_ensure('present') }

    it { should contain_file('/var/www/cgi-bin').with_ensure('absent') }

    it { should contain_file("#{VARS[os]['conf']}/conf.d/proxy_ajp.conf").with_ensure('present').with_content(/# File managed by puppet/) }
  end
end
