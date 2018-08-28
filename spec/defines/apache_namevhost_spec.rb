require 'spec_helper'

describe 'apache_c2c::namevhost' do
  let(:pre_condition) do
    "include ::apache_c2c"
  end

  let(:title) { '*:8080' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_class('apache_c2c::params') }

      ['present', 'absent'].each do |e|
        describe "ensuring #{e}" do
          let(:params) { {
            :ensure => e,
          } }

          case facts[:osfamily]
          when 'Debian'
            if e == 'present'
              it { should contain_concat__fragment('apache-namevhost.conf-*:8080').with( {
                'content' => "NameVirtualHost *:8080\n",
                'target'  => '/etc/apache2/ports.conf',
              } ) }
            else
              it { should_not contain_concat__fragment('apache-namevhost.conf-*:8080').with( {
                'content' => "NameVirtualHost *:8080\n",
                'target'  => '/etc/apache2/ports.conf',
              } ) }
            end
          else
            if e == 'present'
              it { should contain_concat__fragment('apache-namevhost.conf-*:8080').with( {
                'content' => "NameVirtualHost *:8080\n",
                'target'  => '/etc/httpd/ports.conf',
              } ) }
            else
              it { should_not contain_concat__fragment('apache-namevhost.conf-*:8080').with( {
                'content' => "NameVirtualHost *:8080\n",
                'target'  => '/etc/httpd/ports.conf',
              } ) }
            end
          end
        end
      end
    end
  end
end
