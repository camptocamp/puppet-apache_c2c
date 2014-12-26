require 'spec_helper'

describe 'apache_c2c' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Debian'
        it { should contain_class('apache_c2c::debian') }
      when 'RedHat'
        it { should contain_class('apache_c2c::redhat') }
      end
    end
  end
end
