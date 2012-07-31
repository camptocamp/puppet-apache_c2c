require 'spec_helper'

describe 'apache::vhost' do
  vhost = 'www.example.com'
  let(:title) { vhost }
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      describe 'ensuring present with defaults' do
        it { should contain_file("#{VARS[os]['conf']}/sites-available/#{vhost}").with(
          :ensure  => 'present',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :seltype => VARS[os]['conf_seltype'],
          :content => /^# file managed by puppet$/
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}").with(
          :ensure  => 'directory',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :seltype => VARS[os]['cont_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/conf").with(
          :ensure  => 'directory',
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['conf_seltype'],
          :source  => nil
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/htdocs").with(
          :ensure  => 'directory',
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['cont_seltype'],
          :source  => nil
        ) }

        it { should contain_file("#{vhost} cgi-bin directory").with(
          :ensure  => 'directory',
          :path    => "#{VARS[os]['root']}/#{vhost}/cgi-bin/",
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['script_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/logs").with(
          :ensure  => 'directory',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :seltype => VARS[os]['log_seltype']
        ) }

        ['access', 'error'].each do |f|
          it { should contain_file("#{VARS[os]['root']}/#{vhost}/logs/#{f}.log").with(
            :ensure  => 'present',
            :owner   => 'root',
            :group   => 'adm',
            :mode    => '0644',
            :seltype => VARS[os]['log_seltype']
          ) }
        end

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/private").with(
          :ensure  => 'directory',
          :owner   => VARS[os]['user'],
          :group   => VARS[os]['group'],
          :mode    => '2570',
          :seltype => VARS[os]['cont_seltype']
        ) }

        it { should contain_file("#{VARS[os]['root']}/#{vhost}/README").with(
          :ensure  => 'present',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :content => /^Your website is hosted in #{VARS[os]['root']}\/#{vhost}\/$/
        ) }

        it { should contain_exec("enable vhost #{vhost}").with(
          :command => "#{VARS[os]['a2ensite']} #{vhost}"
        ) }
      end

      describe 'ensuring absent' do
        let(:params) { {
          :ensure => 'absent',
        } }

        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/#{vhost}").with_ensure('absent') }
        it { should contain_file("#{VARS[os]['conf']}/sites-available/#{vhost}").with_ensure('absent') }

        it { should contain_exec("remove #{VARS[os]['root']}/#{vhost}").with(
          :command => "rm -rf #{VARS[os]['root']}/#{vhost}",
          :onlyif  => "test -d #{VARS[os]['root']}/#{vhost}"
        ) }

        it { should contain_exec("disable vhost #{vhost}").with(
          :command => "#{VARS[os]['a2dissite']} #{vhost}"
        ) }
      end

      describe 'ensuring disabled' do
        let(:params) { {
          :ensure => 'disabled',
        } }

        it { should contain_exec("disable vhost #{vhost}").with(
          :command => "#{VARS[os]['a2dissite']} #{vhost}"
        ) }

        it { should contain_file("#{VARS[os]['conf']}/sites-enabled/#{vhost}").with(
          :ensure => 'absent'
        ) }
      end

      describe 'using wrong ensure value' do
        let(:params) { {
          :ensure => 'running',
        } }

        it do
          expect {
            should contain_file("#{VARS[os]['conf']}/sites-enabled/#{vhost}")
          }.to raise_error(Puppet::Error, /Unknown ensure value: 'running'/)
        end
      end
    end
  end
end
