require 'spec_helper'

describe 'apache_c2c::ssl' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      if ['Debian', 'Ubuntu'].include? os
        it { should contain_class('apache_c2c::ssl::debian') }
      elsif ['RedHat', 'CentOS'].include? os
        it { should contain_class('apache_c2c::ssl::redhat') }
      end
    end
  end
end
