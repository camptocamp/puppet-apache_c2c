require 'spec_helper'

describe 'apache::balancer' do
  let(:title) { 'my balanced service' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      let(:params) { {
        :vhost => 'default.org',
      } }

      it { should contain_apache__module('proxy') }
      it { should contain_apache__module('proxy_balancer') }
      describe 'using defaults' do

        it { should contain_apache__module('proxy_http') }
        it do should contain_file('my balanced service balancer on default.org').with(
          :ensure => 'present',
          :path   => "#{VARS[os]['root']}/default.org/conf/balancer-my_balanced_service.conf"
        ) end
      end

      describe 'using example usage' do
        let(:params) { {
          :ensure     => 'present',
          :location   => '/mywebapp/',
          :proto      => 'ajp',
          :members    => [
            'node1.cluster:8009',
            'node2.cluster:8009',
            'node3.cluster:8009'
          ],
          :params     => ['retry=20', 'min=3', 'flushpackets=auto'],
          :standbyurl => 'http://sorryserver.cluster/',
          :vhost      => 'www.example.com',
          :filename   => 'balancer1.conf'
        } }

        it { should contain_apache__module('proxy_ajp') }
        it do should contain_file('my balanced service balancer on www.example.com').with(
          :ensure => 'present',
          :path   => "#{VARS[os]['root']}/www.example.com/conf/balancer1.conf"
        ) end
      end

      describe 'ensuring absent' do
        let(:params) { {
          :ensure => 'absent',
          :vhost  => 'www.example.com',
        } }

        it { should include_class('apache::params') }

        it { should contain_apache__module('proxy').with_ensure('absent') }
        it { should contain_apache__module('proxy_balancer').with_ensure('absent') }
        it { should contain_apache__module('proxy_http').with_ensure('absent') }
        it { should contain_file('my balanced service balancer on www.example.com').with_ensure('absent') }
      end

      describe 'passing wrong proto' do
        let(:params) { {
          :ensure => 'present',
          :vhost  => 'www.example.com',
          :proto  => 'foobar',
        } }

        it do
          expect {
            should include_class('apache::params')
          }.to raise_error(Puppet::Error, /foo/)
        end
      end
    end
  end
end
