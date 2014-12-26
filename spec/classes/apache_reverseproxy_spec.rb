require 'spec_helper'

describe 'apache_c2c::reverseproxy' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_class('apache_c2c::params') }

      ['proxy', 'proxy_http', 'proxy_ajp', 'proxy_connect'].each do |m|
        it { should contain_apache_c2c__module(m).with_ensure('present') }
      end

      it { should contain_file('reverseproxy.conf').with(
        'ensure'  => 'present',
        'path'    => "#{VARS[os]['conf']}/conf.d/reverseproxy.conf"
      ) }
    end
  end
end
