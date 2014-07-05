require 'spec_helper'

describe 'apache_c2c::security' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
        :osfamily        => os,
      } }

      it { should contain_package(VARS[os]['mod_security']).with(
        'ensure' => 'present',
        'alias'  => 'apache-mod_security'
      ) }

      if ['RedHat', 'CentOS'].include? os
        it { should contain_file('/etc/httpd/conf.d/mod_security.conf').with_ensure('present') }
      end

      ['unique_id', 'security'].each do |m|
        it { should contain_apache_c2c__module(m).with_ensure('present') }
      end

    end
  end

end
