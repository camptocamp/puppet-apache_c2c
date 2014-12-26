require 'spec_helper'

skel_directories = ['htdocs', 'conf', 'cgi-bin', 'private']

describe 'apache_c2c::userdir' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_file('/etc/skel/public_html').with_ensure('directory') }
      skel_directories.each do |d|
        it { should contain_file("/etc/skel/public_html/#{d}").with_ensure('directory') }
      end
    end
  end
end
