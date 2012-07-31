require 'spec_helper'

describe 'apache::listen' do
  let(:title) { '80' }
  let(:pre_condition) { "define common::concatfilepart($ensure, $manage, $content, $file) {}" }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      it do should contain_common__concatfilepart('apache-ports.conf-80').with(
        'ensure'  => 'present',
        'manage'  => 'true',
        'content' => "Listen 80\n",
        'file'    => "#{VARS[os]['conf']}/ports.conf"
      ) end
    end
  end
end
