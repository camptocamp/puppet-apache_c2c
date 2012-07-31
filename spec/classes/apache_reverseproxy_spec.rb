require 'spec_helper'

describe 'apache::reverseproxy' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      REVERSEPROXY_MODULES.each do |m|
        it { should contain_apache__module(m).with_ensure('present') }
      end

      it { should contain_file('reverseproxy.conf').with(
        'ensure'  => 'present',
        'path'    => "#{VARS[os]['conf']}/conf.d/reverseproxy.conf"
      ) }
    end
  end
end
