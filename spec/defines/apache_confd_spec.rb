require 'spec_helper'

describe 'apache::confd' do
  let(:title) { 'example 1' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os
      } }

      describe 'using example usage' do
        let(:params) { {
          :ensure        => 'present',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs'
        } }

        it { should include_class('apache::params') }

        it do should contain_apache__conf('example 1').with(
          'ensure'        => 'present',
          'path'          => "#{VARS[os]['conf']}/conf.d",
          'filename'      => '',
          'configuration' => 'WSGIPythonEggs /var/cache/python-eggs'
        ) end
      end

      describe 'ensuring absence of example usage' do
        let(:params) { {
          :ensure        => 'absent',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs'
        } }

        it { should include_class('apache::params') }

        it do should contain_apache__conf('example 1').with(
          'ensure'        => 'absent',
          'path'          => "#{VARS[os]['conf']}/conf.d",
          'filename'      => '',
          'configuration' => 'WSGIPythonEggs /var/cache/python-eggs'
        ) end
      end
    end
  end
end
