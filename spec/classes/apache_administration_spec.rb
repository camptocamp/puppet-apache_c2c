require 'spec_helper'

describe 'apache::administration' do
  let(:pre_condition) { "define sudo::directive($ensure, $content) {}" }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      it { should contain_sudo__directive('apache-administration').with_ensure('present') }
    end
  end
end


