require 'spec_helper'

describe 'apache_c2c::vhost' do
  vhost = 'www.example.com'
  let(:title) { vhost }
  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      case facts[:osfamily]
      when 'Debian'
        let(:a2ensite) { '/usr/sbin/a2ensite' }
        let(:a2dissite) { '/usr/sbin/a2dissite' }
        let(:conf) { '/etc/apache2' }
        let(:group) { 'www-data' }
        let(:root) { '/var/www' }
        let(:user) { 'www-data' }
      else
        let(:a2ensite) { '/usr/local/sbin/a2ensite' }
        let(:a2dissite) { '/usr/local/sbin/a2dissite' }
        let(:conf) { '/etc/httpd' }
        let(:group) { 'apache' }
        let(:root) { '/var/www/vhosts' }
        let(:user) { 'apache' }
      end
      let(:conf_seltype) { 'httpd_config_t' }
      let(:cont_seltype) { 'httpd_sys_content_t' }
      let(:log_seltype) { 'httpd_log_t' }
      let(:script_seltype) { 'httpd_sys_script_exec_t' }

      it { should contain_class('apache_c2c::params') }

      describe 'ensuring present with defaults' do
        it { should contain_file("#{conf}/sites-available/25-#{vhost}.conf").with( {
          :ensure  => 'file',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :seltype => conf_seltype,
        } ) }

        it { should contain_file("#{root}/#{vhost}").with( {
          :ensure  => 'directory',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :seltype => cont_seltype,
        } ) }

        it { should contain_file("#{root}/#{vhost}/conf").with( {
          :ensure  => 'directory',
          :owner   => user,
          :group   => group,
          :mode    => '2570',
          :seltype => conf_seltype,
          :source  => nil,
        } ) }

        it { should contain_file("#{root}/#{vhost}/htdocs").with( {
          :ensure  => 'directory',
          :owner   => user,
          :group   => group,
          :mode    => '2570',
          :seltype => cont_seltype,
          :source  => nil,
        } ) }

        it { should contain_file("#{root}/#{vhost} cgi-bin directory").with({ 
          :ensure  => 'directory',
          :path    => "#{root}/#{vhost}/cgi-bin/",
          :owner   => user,
          :group   => group,
          :mode    => '2570',
          :seltype => script_seltype,
        } ) }

        it { should contain_file("#{root}/#{vhost}/logs").with( {
          :ensure  => 'directory',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0755',
          :seltype => log_seltype,
        } ) }

        ['access', 'error'].each do |f|
          it { should contain_file("#{root}/#{vhost}/logs/#{f}.log").with( {
            :ensure  => 'present',
            :owner   => 'root',
            :group   => 'adm',
            :mode    => '0644',
            :seltype => log_seltype,
          } ) }
        end

        it { should contain_file("#{root}/#{vhost}/private").with( {
          :ensure  => 'directory',
          :owner   => user,
          :group   => group,
          :mode    => '2570',
          :seltype => cont_seltype,
        } ) }

        it { should contain_exec("enable vhost #{vhost}").with(
          :command => "#{a2ensite} 25-#{vhost}.conf"
        ) }
      end

      describe 'ensuring absent' do
        let(:params) { {
          :ensure => 'absent',
        } }

        it { should contain_file("#{conf}/sites-enabled/25-#{vhost}.conf").with_ensure('absent') }
        it { should contain_file("#{conf}/sites-available/25-#{vhost}.conf").with_ensure('absent') }

        it { should contain_exec("remove #{root}/#{vhost}").with( {
          :command => "rm -rf #{root}/#{vhost}",
          :onlyif  => "test -d #{root}/#{vhost}"
        } ) }

        it { should contain_exec("disable vhost #{vhost}").with( {
          :command => "#{a2dissite} 25-#{vhost}.conf"
        } ) }
      end

      describe 'ensuring disabled' do
        let(:params) { {
          :ensure => 'disabled',
        } }

        it { should contain_exec("disable vhost #{vhost}").with( {
          :command => "#{a2dissite} 25-#{vhost}.conf"
        } ) }

        it { should contain_file("#{conf}/sites-enabled/25-#{vhost}.conf").with( {
          :ensure => 'absent'
        } ) }
      end

      describe 'using wrong ensure value' do
        let(:params) { {
          :ensure => 'running',
        } }

        it do
          expect {
            should contain_file("#{conf}/sites-enabled/#{vhost}")
          }.to raise_error(/Unknown ensure value: 'running'/)
        end
      end
    end
  end
end
