require 'spec_helper'

describe 'apache::directive' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      describe 'using example usage 1' do
        let(:title) { 'example 1' }
        let(:params) { {
          :ensure    => 'present',
          :directive => "\nRewriteEngine on\nRewriteRule ^/?$ https://www.example.com/\n",
          :vhost     => 'www.example.com',
        } }

        it { should include_class('apache::params') }

        it do should contain_apache__conf('example 1').with(
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

        it { should include_class('apache::params') }

        it { should contain_apache__conf('example 1').with_ensure('absent') }
      end
    end
  end
end
