require 'spec_helper'

describe 'apache::deflate' do
  OSES.each do |os|
    describe "When on #{os}" do
      let(:facts) { {
        :operatingsystem => os,
      } }

      it { should include_class('apache::params') }

      it { should contain_apache__module('deflate').with_ensure('present') }

      it do should contain_file('deflate.conf').with(
        'ensure'  => 'present',
        'path'    => "#{VARS[os]['conf']}/conf.d/deflate.conf",
        'content' => '# file managed by puppet
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE application/x-javascript application/javascript text/css
  BrowserMatch Safari/4 no-gzip
</IfModule>
'
      ) end
    end
  end
end
