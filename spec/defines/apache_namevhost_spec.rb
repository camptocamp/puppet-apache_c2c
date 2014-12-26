require 'spec_helper'

describe 'apache_c2c::namevhost' do
  let(:title) { '*:80' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_class('apache_c2c::params') }

      ['present', 'absent'].each do |e|
        describe "ensuring #{e}" do
          let(:params) { {
            :ensure => e,
          } }

          it { should contain_concat__fragment('apache-namevhost.conf-*:80').with(
            'ensure'  => e,
            'content' => "NameVirtualHost *:80\n",
            'target'    => "#{VARS[os]['conf']}/ports.conf"
          ) }
        end
      end
    end
  end
end
