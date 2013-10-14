require 'spec_helper'

describe 'apache::collectd' do
  let(:pre_condition) {
    "define collectd::plugin($ensure='present', $lines) {}"
  }

  OSES.each do |os|
    describe "When on #{os}" do
      if ['RedHat', 'CentOS'].include? os
        describe "with os version 4" do
	  let(:facts) { {
            :operatingsystem   => os,
            :lsbmajdistrelease => '4'
	  } }

	  it { should_not contain_package('collectd-apache').with_ensure('present') }

	  it { should contain_collectd__plugin('apache').with_lines('URL "http://localhost/server-status?auto"') }
	end
        describe "with os version 5" do
	  let(:facts) { {
            :operatingsystem   => os,
            :lsbmajdistrelease => '5'
	  } }

	  it { should contain_package('collectd-apache').with_ensure('present') }

	  it { should contain_collectd__plugin('apache').with_lines('URL "http://localhost/server-status?auto"') }
	end
      else
	let(:facts) { {
          :operatingsystem   => os,
          :lsbmajdistrelease => '4'
	} }

	it { should_not contain_package('collectd-apache').with_ensure('present') }

	it { should contain_collectd__plugin('apache').with_lines('URL "http://localhost/server-status?auto"') }
      end
    end
  end
end
