require 'spec_helper'

describe 'apache::namevhost' do
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }
  let(:title) { '*:80' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

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
