require 'spec_helper'

describe 'apache::module' do
  let(:title) { 'deflate' }
  OSES.each do |os|
    describe "When on #{os}" do
      let (:facts) { {
        :operatingsystem => os,
      } }

      describe 'ensuring presence' do
        let(:params) { {
          :ensure => 'present',
        } }

        it { should include_class('apache::params') }

        describe "using selinux" do
          let (:facts) { {
            :operatingsystem => os,
            :selinux         => 'true',
          } }

          it { should contain_apache__redhat__selinux('deflate') }

          it do should contain_exec('a2enmod deflate').with(
            'command' => "#{VARS[os]['a2enmod']} deflate"
          ) end
        end
      end

      describe 'ensuring absence' do
        let(:params) { {
          :ensure => 'absent',
        } }

        it { should include_class('apache::params') }

        it { should_not contain_apache__redhat__selinux('deflate') }

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
