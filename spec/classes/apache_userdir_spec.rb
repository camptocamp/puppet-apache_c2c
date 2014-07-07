require 'spec_helper'

skel_directories = ['htdocs', 'conf', 'cgi-bin', 'private']

describe 'apache_c2c::userdir' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :concat_basedir  => '/foo',
        :operatingsystem => os,
        :osfamily        => os,
      } }

      it { should contain_file('/etc/skel/public_html').with_ensure('directory') }
      skel_directories.each do |d|
        it { should contain_file("/etc/skel/public_html/#{d}").with_ensure('directory') }
      end
    end
  end
end
