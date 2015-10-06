require 'spec_helper'

describe 'apache_c2c::security' do

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

      it { is_expected.to compile.with_all_deps }

      case facts[:osfamily]
      when 'Debian'
        it { should contain_package('apache-mod_security').with({
          :ensure => 'present',
          :name   => 'libapache-mod-security',
        } ) }
      else
        it { should contain_package('apache-mod_security').with({
          :ensure => 'present',
          :name   => 'mod_security',
        } ) }
      end

      if ['RedHat', 'CentOS'].include? os
        it { should contain_file('/etc/httpd/conf.d/mod_security.conf').with_ensure('present') }
      end

      ['unique_id', 'security'].each do |m|
        it { should contain_apache_c2c__module(m).with_ensure('present') }
      end

    end
  end

end
