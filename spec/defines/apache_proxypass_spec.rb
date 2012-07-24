require 'spec_helper'

describe 'apache::proxypass' do
  let(:title) { 'proxy legacy dir to legacy server' }
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      describe 'using example usage' do
        let(:params) { {
          :ensure   => 'present',
          :location => '/legacy/',
          :url      => 'http://legacyserver.example.com',
          :params   => ['retry=5', 'ttl=120'],
          :vhost    => 'www.example.com',
        } }

        it { should include_class('apache::params') }

        it { should contain_apache__module('proxy').with_ensure('present') }
        it { should contain_apache__module('proxy_http').with_ensure('present') }

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

        it { should include_class('apache::params') }

        it { should contain_apache__module('proxy').with_ensure('absent') }
        it { should contain_apache__module('proxy_http').with_ensure('absent') }
        it { should contain_file('proxy legacy dir to legacy server proxypass on www.example.com').with_ensure('absent') }
      end

      describe 'without vhost parameter' do
        let(:params) { {
          :ensure => 'present',
        } }

        it do
          expect {
            should include_class('apache::params')
          }.to raise_error(Puppet::Error, /Must pass vhost to Apache::Proxypass\[proxy legacy dir to legacy server\]/)
        end
      end
    end
  end
end
