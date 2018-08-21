require 'spec_helper'

describe 'apache_c2c::listen' do
  let(:pre_condition) do
    "include ::apache_c2c"
  end

  let(:title) { '8080' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_class('apache_c2c::params') }

      case facts[:osfamily]
      when 'Debian'
        it { should contain_concat__fragment('apache-ports.conf-8080').with( {
          'content' => "Listen 8080\n",
          'target'  => '/etc/apache2/ports.conf',
        } ) }
      else
        it { should contain_concat__fragment('apache-ports.conf-8080').with( {
          'content' => "Listen 8080\n",
          'target'  => '/etc/httpd/ports.conf',
        } ) }
      end
    end
  end
end
