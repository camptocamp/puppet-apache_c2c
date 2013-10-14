require 'spec_helper'

describe 'apache::conf' do
  let(:title) { 'example 1' }

  OSES.each do |os|
    describe "When on #{os}" do
      describe 'using example usage' do
        let(:params) { {
          :ensure        => 'present',
          :path          => '/var/www/foo/conf',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs',
        } }

        it do should contain_file('example 1 configuration in /var/www/foo/conf').with(
          :ensure  => 'present',
          :content => "# file managed by puppet\nWSGIPythonEggs /var/cache/python-eggs\n",
          :path    => '/var/www/foo/conf/configuration-example_1.conf',
          :seltype => VARS[os]['conf_seltype']
          ) end
      end

      describe 'ensuring absence of example usage' do
        let(:params) { {
          :ensure        => 'absent',
          :path          => '/var/www/foo/conf',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs',
        } }

        it { should contain_file('example 1 configuration in /var/www/foo/conf').with_ensure('absent') }
      end

      describe 'setting filename' do
        let(:params) { {
          :ensure        => 'present',
          :path          => '/var/www/foo/conf',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs',
          :filename      => 'myparams.conf',
        } }

        it do should contain_file('example 1 configuration in /var/www/foo/conf').with(
          :ensure  => 'present',
          :content => "# file managed by puppet\nWSGIPythonEggs /var/cache/python-eggs\n",
          :path    => '/var/www/foo/conf/myparams.conf',
          :seltype => VARS[os]['conf_seltype']
          ) end
      end

      describe 'setting prefix' do
        let(:params) { {
          :ensure        => 'present',
          :path          => '/var/www/foo/conf',
          :configuration => 'WSGIPythonEggs /var/cache/python-eggs',
          :prefix        => 'aconf',
        } }

        it do should contain_file('example 1 configuration in /var/www/foo/conf').with(
          :ensure  => 'present',
          :content => "# file managed by puppet\nWSGIPythonEggs /var/cache/python-eggs\n",
          :path    => '/var/www/foo/conf/aconf-example_1.conf',
          :seltype => VARS[os]['conf_seltype']
          ) end
      end
    end
  end
end
