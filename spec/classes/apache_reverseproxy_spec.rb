require 'spec_helper'

describe 'apache_c2c::reverseproxy' do

  let(:pre_condition) do
    "include ::apache_c2c"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_class('apache_c2c::params') }

      ['proxy', 'proxy_http', 'proxy_ajp', 'proxy_connect'].each do |m|
        it { should contain_apache_c2c__module(m).with_ensure('present') }
      end

      case facts[:osfamily]
      when 'Debian'
        it { should contain_file('reverseproxy.conf').with( {
          'ensure'  => 'file',
          'path'    => '/etc/apache2/conf.d/reverseproxy.conf',
        } ) }
      else
        it { should contain_file('reverseproxy.conf').with( {
          'ensure'  => 'file',
          'path'    => '/etc/httpd/conf.d/reverseproxy.conf',
        } ) }
      end
    end
  end
end
