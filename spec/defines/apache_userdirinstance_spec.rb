require 'spec_helper'

describe 'apache_c2c::userdirinstance' do
  let(:title) { 'foo' }
  let(:pre_condition) { 'include ::apache_c2c' }
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir    => '/foo',
        :lsbmajdistrelease => '6',
        :operatingsystem   => os,
        :osfamily          => os,
      } }

      describe 'using example vhost' do
        let(:params) { {
          :vhost => 'www.example.com',
        } }

        it { should contain_file("#{VARS[os]['root']}/www.example.com/conf/userdir.conf").with(
          :ensure  => 'present',
          :source  => 'puppet:///modules/apache_c2c/userdir.conf',
          :seltype => VARS[os]['conf_seltype']
        ) }
      end

      describe 'ensuring absence' do
        let(:params) { {
	  :ensure => 'absent',
	  :vhost  => 'www.example.com',
	} }

        it { should contain_file("#{VARS[os]['root']}/www.example.com/conf/userdir.conf").with_ensure('absent') }
      end
    end
  end
end
