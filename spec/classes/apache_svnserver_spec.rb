require 'spec_helper'

describe 'apache::svnserver' do
  let(:pre_condition) { "
class concat::setup {}
define concat() {}
define concat::fragment($ensure='present', $target, $content) {}
  " }
 
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem   => os,
        :lsbmajdistrelease => '5',
      } }

      it { should contain_package(VARS[os]['mod_svn']).with_ensure('present') }

      it { should contain_apache__module('dav').with_ensure('present') }
      it { should contain_apache__module('dav_svn').with_ensure('present') }

    end
  end
end
