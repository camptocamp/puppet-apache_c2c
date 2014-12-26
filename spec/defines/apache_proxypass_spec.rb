require 'spec_helper'

describe 'apache_c2c::proxypass' do
  let(:title) { 'proxy legacy dir to legacy server' }
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'using example usage' do
        let(:params) { {
          :ensure   => 'present',
          :location => '/legacy/',
          :url      => 'http://legacyserver.example.com',
          :params   => ['retry=5', 'ttl=120'],
          :vhost    => 'www.example.com',
        } }

        it { should contain_class('apache_c2c::params') }

        it { should contain_apache_c2c__module('proxy').with_ensure('present') }
        it { should contain_apache_c2c__module('proxy_http').with_ensure('present') }

        it { should contain_file('proxy legacy dir to legacy server proxypass on www.example.com').with(
          'ensure'  => 'present',
          'seltype' => VARS[os]['conf_seltype'],
          'path'    => "#{VARS[os]['root']}/www.example.com/conf/proxypass-proxy_legacy_dir_to_legacy_server.conf"
        ) }
      end

      describe 'ensuring absent' do
        let(:params) { {
          :ensure => 'absent',
          :vhost  => 'www.example.com',
        } }

        it { should contain_class('apache_c2c::params') }

        it { should contain_apache_c2c__module('proxy') }
        it { should contain_apache_c2c__module('proxy_http') }
        it { should contain_file('proxy legacy dir to legacy server proxypass on www.example.com').with_ensure('absent') }
      end

      describe 'without vhost parameter' do
        let(:params) { {
          :ensure => 'present',
        } }

        it do
          expect {
            should contain_class('apache_c2c::params')
          }.to raise_error(Puppet::Error, /Must pass vhost to Apache_c2c::Proxypass\[proxy legacy dir to legacy server\]/)
        end
      end
    end
  end
end
