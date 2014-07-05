require 'spec_helper'

describe 'apache_c2c::namevhost' do
  let(:title) { '*:80' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir  => '/foo',
        :operatingsystem => os,
        :osfamily        => os,
      } }

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
