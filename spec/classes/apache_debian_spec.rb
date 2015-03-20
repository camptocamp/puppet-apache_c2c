require 'spec_helper'

describe 'apache_c2c::debian' do
  let(:pre_condition) { "include ::apache_c2c" }

  on_supported_os.select { |os| os =~ /debian/ }.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_class('apache_c2c::params') }

      describe 'using default values' do
        let(:root) { '/var/www' }
        let(:conf) { '/etc/apache2' }

        it { should contain_package('apache2-mpm-prefork').with_ensure('installed') }

        it do should contain_file("#{root}/apache2-default").with(
          'ensure' => 'absent',
          'force'  => 'true'
        ) end

        it { should contain_file("#{root}/index.html").with_ensure('absent') }

        it { should contain_file("#{root}/html").with_ensure('directory') }

        it do should contain_file("#{root}/html/index.html").with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => "<html><body><h1>It works!</h1></body></html>\n"
        ) end

        it { should contain_file("#{conf}/conf.d/servername.conf").with_content("ServerName foo.example.com\n") }
      end
    end
  end
end
