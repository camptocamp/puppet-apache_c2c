require 'spec_helper'

describe 'apache_c2c::directive' do
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'using example usage 1' do
        let(:title) { 'example 1' }
        let(:params) { {
          :ensure    => 'present',
          :directive => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n",
          :vhost     => 'www.example.com',
        } }

        it { should contain_class('apache_c2c::params') }

        it do should contain_apache_c2c__conf('example 1').with(
          'ensure'        => 'present',
          'path'          => "#{VARS[os]['root']}/www.example.com/conf",
          'prefix'        => 'directive',
          'filename'      => '',
          'configuration' => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n"
        ) end
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
