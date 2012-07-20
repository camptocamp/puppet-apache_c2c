require 'spec_helper'

describe 'apache::aw-stats' do
  let(:title) { 'foo' }

  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      it { should contain_file('/etc/awstats/awstats.foo.conf').with_ensure('present') }

      it do should contain_file("#{VARS[os]['root']}/foo/conf/awstats.conf").with(
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'source'  => VARS[os]['awstats_tmpl']
      ) end
    end
  end
end
