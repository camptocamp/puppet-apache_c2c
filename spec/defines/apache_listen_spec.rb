require 'spec_helper'

describe 'apache::listen' do
  let(:title) { '80' }
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      it do should contain_concat__fragment('apache-ports.conf-80').with(
        'ensure'  => 'present',
        'content' => "Listen 80\n",
        'target'  => "#{VARS[os]['conf']}/ports.conf"
      ) end
    end
  end
end
