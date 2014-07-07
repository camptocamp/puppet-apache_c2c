require 'spec_helper'

describe 'apache_c2c::listen' do
  let(:title) { '80' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir  => '/foo',
        :operatingsystem => os,
        :osfamily        => os,
      } }

      it { should contain_class('apache_c2c::params') }

      it do should contain_concat__fragment('apache-ports.conf-80').with(
        'ensure'  => 'present',
        'content' => "Listen 80\n",
        'target'  => "#{VARS[os]['conf']}/ports.conf"
      ) end
    end
  end
end
