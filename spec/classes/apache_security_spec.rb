require 'spec_helper'

describe 'apache::security' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should contain_package(VARS[os]['mod_security']).with(
        'ensure' => 'present',
        'alias'  => 'apache-mod_security'
      ) }

      if ['RedHat', 'CentOS'].include? os
        it { should contain_file('/etc/httpd/conf.d/mod_security.conf').with_ensure('present') }
      end

      ['unique_id', 'security'].each do |m|
        it { should contain_apache__module(m).with_ensure('present') }
      end

    end
  end

  describe 'When on wrong OS' do
    let(:facts) { {
      :operatingsystem => 'Fedora',
    } }

    it do
      expect {
        should contain_file('/etc/httpd/conf.d/mod_security.conf')
      }.to raise_error(Puppet::Error, /Operating system not supported: 'Fedora'/)
    end
  end
end
