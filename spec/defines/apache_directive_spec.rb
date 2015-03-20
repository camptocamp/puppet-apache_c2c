require 'spec_helper'

describe 'apache_c2c::directive' do
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      describe 'using example usage 1' do
        let(:title) { 'example 1' }
        let(:params) { {
          :ensure    => 'present',
          :directive => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n",
          :vhost     => 'www.example.com',
        } }

        it { should contain_class('apache_c2c::params') }

        case facts[:osfamily]
        when 'Debian'
          it { should contain_apache_c2c__conf('example 1').with(
            'ensure'        => 'present',
            'path'          => '/var/www/www.example.com/conf',
            'prefix'        => 'directive',
            'filename'      => '',
            'configuration' => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n"
          ) }
        else
          it { should contain_apache_c2c__conf('example 1').with(
            'ensure'        => 'present',
            'path'          => '/var/www/vhosts/www.example.com/conf',
            'prefix'        => 'directive',
            'filename'      => '',
            'configuration' => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n"
          ) }
        end
      end

      describe 'ensuring example usage 1 is absent' do
        let(:title) { 'example 1' }
        let(:params) { {
          :ensure    => 'absent',
          :directive => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n",
          :vhost     => 'www.example.com',
        } }

        it { should contain_class('apache_c2c::params') }

        it { should contain_apache_c2c__conf('example 1').with_ensure('absent') }
      end
    end
  end
end
