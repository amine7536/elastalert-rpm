# encoding: utf-8

control 'elastalert-1' do
  impact 1.0
  title 'Elastalert: Check RPM Installation'

  describe package('elastalert') do
    it { should be_installed }
  end

  describe user('elastalert') do
    it { should exist }
    its('group') { should eq 'elastalert' }
    its('home') { should eq '/usr/share/python/elastalert' }
    its('shell') { should eq '/sbin/nologin' }
  end

  describe systemd_service('elastalert') do
    it { should be_installed }
    it { should_not be_enabled }
    it { should_not be_running }
  end

  describe file('/etc/elastalert/config.yml') do
    it { should exist }
  end

  describe file('/etc/sysconfig/elastalert') do
    it { should exist }
  end
  
  describe file('/usr/lib/systemd/system/elastalert.service') do
    it { should exist }
  end
end

