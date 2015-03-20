require 'spec_helper'

describe 'apache_c2c::proxypass' do
  let(:title) { 'proxy legacy dir to legacy server' }
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
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

        case facts[:osfamily]
        when 'Debian'
          it { should contain_file('proxy legacy dir to legacy server proxypass on www.example.com').with(
            'ensure'  => 'present',
            'seltype' => nil,
            'path'    => '/var/www/www.example.com/conf/proxypass-proxy_legacy_dir_to_legacy_server.conf',
          ) }
        else
          it { should contain_file('proxy legacy dir to legacy server proxypass on www.example.com').with(
            'ensure'  => 'present',
            'seltype' => 'httpd_config_t',
            'path'    => '/var/www/vhosts/www.example.com/conf/proxypass-proxy_legacy_dir_to_legacy_server.conf',
          ) }
        end
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
          }.to raise_error(/Must pass vhost to Apache_c2c::Proxypass\[proxy legacy dir to legacy server\]/)
        end
      end
    end
  end
end
