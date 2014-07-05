require 'spec_helper'

describe 'apache_c2c::confd' do
  let(:title) { 'example 1' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir  => '/foo',
        :operatingsystem => os,
        :osfamily        => os,
      } }

      describe 'using example usage' do
        let(:params) { {
          :ensure        => 'present',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs'
        } }

        it { should contain_class('apache_c2c::params') }

        it do should contain_apache_c2c__conf('example 1').with(
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

        it { should contain_class('apache_c2c::params') }

        it do should contain_apache_c2c__conf('example 1').with(
          'ensure'        => 'absent',
          'path'          => "#{VARS[os]['conf']}/conf.d",
          'filename'      => '',
          'configuration' => 'WSGIPythonEggs /var/cache/python-eggs'
        ) end
      end
    end
  end
end
