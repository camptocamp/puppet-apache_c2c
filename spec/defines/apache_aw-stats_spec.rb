require 'spec_helper'

describe 'apache_c2c::aw-stats' do
  let(:title) { 'foo' }

  let(:pre_condition) { 'include ::apache_c2c' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should contain_class('apache_c2c::params') }

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
