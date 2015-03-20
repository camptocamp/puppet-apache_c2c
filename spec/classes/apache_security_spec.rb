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

      case facts[:osfamily]
      when 'Debian'
        it { should contain_package('libapache-mod-security').with(
          'ensure' => 'present',
          'alias'  => 'apache-mod_security'
        ) }
      else
        it { should contain_package('mod_security').with(
          'ensure' => 'present',
          'alias'  => 'apache-mod_security'
        ) }
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
