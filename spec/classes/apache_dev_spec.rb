require 'spec_helper'

describe 'apache::dev' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it do should contain_package('apache-devel').with(
        'ensure' => 'present',
        'name'   => VARS[os]['apache_devel']
      ) end
    end
  end
end
