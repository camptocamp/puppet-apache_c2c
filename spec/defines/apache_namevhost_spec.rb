require 'spec_helper'

describe 'apache::namevhost' do
  let(:pre_condition) { "define common::concatfilepart($ensure, $manage, $content, $file) {}" }
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

          it { should contain_common__concatfilepart('apache-namevhost.conf-*:80').with(
            'ensure'  => e,
            'manage'  => 'true',
            'content' => "NameVirtualHost *:80\n",
            'file'    => "#{VARS[os]['conf']}/ports.conf"
          ) }
        end
      end
    end
  end
end
