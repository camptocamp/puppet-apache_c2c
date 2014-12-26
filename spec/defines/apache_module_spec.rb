require 'spec_helper'

describe 'apache_c2c::module' do
  let(:title) { 'deflate' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'ensuring presence' do
        let(:params) { {
          :ensure => 'present',
        } }

        it { should contain_class('apache_c2c::params') }

        describe "using selinux" do
          let (:facts) { {
            :operatingsystem => os,
            :osfamily        => os,
            :selinux         => 'true',
          } }

          it { should contain_apache_c2c__redhat__selinux('deflate') }

          it do should contain_exec('a2enmod deflate').with(
            'command' => "#{VARS[os]['a2enmod']} deflate"
          ) end
        end
      end

      describe 'ensuring absence' do
        let(:params) { {
          :ensure => 'absent',
        } }

        it { should contain_class('apache_c2c::params') }

        it { should_not contain_apache_c2c__redhat__selinux('deflate') }

        it do should contain_exec('a2dismod deflate').with(
          'command' => "#{VARS[os]['a2dismod']} deflate"
        ) end
      end

      describe 'using wrong value of ensure' do
        let(:params) { {
          :ensure => 'running',
        } }

        it do
          expect {
            should contain_exec('a2enmode deflate')
          }.to raise_error(Puppet::Error, /Unknown ensure value: 'running'/)
        end
      end
    end

  end
end
