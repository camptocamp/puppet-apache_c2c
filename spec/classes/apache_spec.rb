require 'spec_helper'

describe 'apache_c2c' do
  OSES.each do |os|
    describe "When on #{os}" do
      if ['Debian', 'Ubuntu'].include? os
        let(:facts) { {
          :concat_basedir  => '/foo',
          :operatingsystem => os,
          :osfamily        => os,
        } }

        it { should contain_class('apache_c2c::debian') }
      elsif ['RedHat', 'CentOS'].include? os
        # NOTE: RHEL4 is not supported
        ['5', '6'].each do |release|
          describe "with release #{release}" do
            let(:facts) { {
              :concat_basedir    => '/foo',
              :lsbmajdistrelease => release,
              :operatingsystem   => os,
              :osfamily          => os,
            } }

            it { should contain_class('apache_c2c::redhat') }
          end
        end
      end
    end
  end
end
