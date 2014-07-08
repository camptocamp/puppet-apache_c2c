require 'spec_helper'

describe 'apache_c2c::dev' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :osfamily => os,
      } }

      it do should contain_package('apache-devel').with(
        'ensure' => 'present',
        'name'   => VARS[os]['apache_devel']
      ) end
    end
  end
end
