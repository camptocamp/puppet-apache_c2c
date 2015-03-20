require 'spec_helper'

describe 'apache_c2c::svnserver' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      case facts[:osfamily]
      when 'Debian'
        it { should contain_package('libapache2-svn').with_ensure('present') }
      else
        it { should contain_package('mod_dav_svn').with_ensure('present') }
      end

      it { should contain_apache_c2c__module('dav').with_ensure('present') }
      it { should contain_apache_c2c__module('dav_svn').with_ensure('present') }

    end
  end
end
