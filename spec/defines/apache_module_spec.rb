require 'spec_helper'

describe 'apache_c2c::module' do
  let(:pre_condition) do
   "include ::apache_c2c"
  end

  let(:title) { 'deflate' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      describe 'ensuring presence' do
        let(:params) { {
          :ensure => 'present',
        } }

        it { should contain_class('apache_c2c::params') }

        describe "using selinux" do
          let(:facts) do
            super().merge({
              :selinux => true,
            })
          end

          it { should contain_apache_c2c__redhat__selinux('deflate') }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_exec('a2enmod deflate').with( {
              'command' => '/usr/sbin//a2enmod deflate',
            } ) }
          else
            it { should contain_exec('a2enmod deflate').with( {
              'command' => '/usr/local/sbin//a2enmod deflate',
            } ) }
          end
        end
      end

      describe 'ensuring absence' do
        let(:params) { {
          :ensure => 'absent',
        } }

        it { should contain_class('apache_c2c::params') }

        it { should_not contain_apache_c2c__redhat__selinux('deflate') }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_exec('a2dismod deflate').with( {
            'command' => '/usr/sbin//a2dismod deflate',
          } ) }
        else
          it { should contain_exec('a2dismod deflate').with( {
            'command' => '/usr/local/sbin//a2dismod deflate',
          } ) }
        end
      end

      describe 'using wrong value of ensure' do
        let(:params) { {
          :ensure => 'running',
        } }

        it do
          expect {
            should contain_exec('a2enmode deflate')
          }.to raise_error(/Unknown ensure value: 'running'/)
        end
      end
    end

  end
end
