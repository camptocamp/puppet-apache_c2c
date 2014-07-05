require 'spec_helper'

describe 'apache_c2c::ssl' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir    => '/foo',
        :lsbmajdistrelease => '5',
        :operatingsystem   => os,
        :osfamily          => os,
      } }

      if ['Debian', 'Ubuntu'].include? os
        it { should contain_class('apache_c2c::ssl::debian') }
      elsif ['RedHat', 'CentOS'].include? os
        it { should contain_class('apache_c2c::ssl::redhat') }
      end
    end
  end
end
