require 'spec_helper'

describe 'apache_c2c::deflate' do
  let(:pre_condition) { "include ::apache_c2c" }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      let(:conf) do
        case facts[:osfamily]
        when 'Debian'
          '/etc/apache2'
        else
          '/etc/httpd'
        end
      end

      it { should contain_class('apache_c2c::params') }

      it { should contain_apache_c2c__module('deflate').with_ensure('present') }

      it do should contain_file('deflate.conf').with(
        'ensure'  => 'file',
        'path'    => "#{conf}/conf.d/deflate.conf",
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
