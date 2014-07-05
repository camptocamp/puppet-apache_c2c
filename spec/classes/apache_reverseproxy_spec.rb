require 'spec_helper'

describe 'apache_c2c::reverseproxy' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
        :osfamily        => os,
      } }

      it { should contain_class('apache_c2c::params') }

      REVERSEPROXY_MODULES.each do |m|
        it { should contain_apache_c2c__module(m).with_ensure('present') }
      end

      it { should contain_file('reverseproxy.conf').with(
        'ensure'  => 'present',
        'path'    => "#{VARS[os]['conf']}/conf.d/reverseproxy.conf"
      ) }
    end
  end
end
