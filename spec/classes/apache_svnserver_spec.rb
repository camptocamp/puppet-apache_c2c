require 'spec_helper'

describe 'apache_c2c::svnserver' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_package(VARS[os]['mod_svn']).with_ensure('present') }

      it { should contain_apache_c2c__module('dav').with_ensure('present') }
      it { should contain_apache_c2c__module('dav_svn').with_ensure('present') }

    end
  end
end
