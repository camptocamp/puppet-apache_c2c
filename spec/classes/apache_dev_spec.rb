require 'spec_helper'

describe 'apache_c2c::dev' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Debian'
        it { should contain_package('apache-devel').with(
          'ensure' => 'present',
          'name'   => 'apache2-threaded-dev',
        ) }
      else
        it { should contain_package('apache-devel').with(
          'ensure' => 'present',
          'name'   => 'httpd-devel',
        ) }
      end
    end
  end
end
