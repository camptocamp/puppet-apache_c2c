require 'spec_helper'

describe 'apache_c2c::debian' do
  let(:pre_condition) { "include ::apache_c2c" }

  let(:node) { "myhost.com" }

  ['Debian'].each do |os|
    describe "When on #{os}" do
      let (:facts) { {
        :concat_basedir  => '/foo',
        :operatingsystem => os,
        :osfamily        => os,
      } }

      it { should contain_class('apache_c2c::params') }

      describe 'using default values' do
        it { should contain_package('apache2-mpm-prefork').with_ensure('installed') }

        it do should contain_file("#{VARS[os]['root']}/apache2-default").with(
          'ensure' => 'absent',
          'force'  => 'true'
        ) end

        it { should contain_file("#{VARS[os]['root']}/index.html").with_ensure('absent') }

        it { should contain_file("#{VARS[os]['root']}/html").with_ensure('directory') }

        it do should contain_file("#{VARS[os]['root']}/html/index.html").with(
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "<html><body><h1>It works!</h1></body></html>\n"
        ) end

        it { should contain_file("#{VARS[os]['conf']}/conf.d/servername.conf").with_content("ServerName myhost.com\n") }
      end
    end
  end
end
