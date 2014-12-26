require 'spec_helper'

describe 'apache_c2c::listen' do
  let(:title) { '80' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_class('apache_c2c::params') }

      it do should contain_concat__fragment('apache-ports.conf-80').with(
        'ensure'  => 'present',
        'content' => "Listen 80\n",
        'target'  => "#{VARS[os]['conf']}/ports.conf"
      ) end
    end
  end
end
