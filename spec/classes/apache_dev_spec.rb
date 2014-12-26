require 'spec_helper'

describe 'apache_c2c::dev' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it do should contain_package('apache-devel').with(
        'ensure' => 'present',
        'name'   => VARS[os]['apache_devel']
      ) end
    end
  end
end
