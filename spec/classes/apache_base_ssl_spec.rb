require 'spec_helper'

describe 'apache_c2c::base::ssl' do
  let(:pre_condition) { "include ::apache_c2c" }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :concat_basedir => '/tmp',
        })
      end

      it { should contain_apache_c2c__listen('443').with_ensure('present') }
      it { should contain_apache_c2c__namevhost('*:443').with_ensure('present') }
    end
  end
end
