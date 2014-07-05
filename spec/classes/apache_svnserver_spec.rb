require 'spec_helper'

describe 'apache_c2c::svnserver' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir    => '/foo',
        :lsbmajdistrelease => '5',
        :operatingsystem   => os,
        :osfamily          => os,
      } }

      it { should contain_package(VARS[os]['mod_svn']).with_ensure('present') }

      it { should contain_apache_c2c__module('dav').with_ensure('present') }
      it { should contain_apache_c2c__module('dav_svn').with_ensure('present') }

    end
  end
end
