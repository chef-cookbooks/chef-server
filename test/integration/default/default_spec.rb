require 'resolv'

describe package('chef-server-core') do
  it { should be_installed }
end

describe file('/etc/opscode/chef-server.rb') do
  its(:content) { should match(/^topology "standalone"$/) }
  its(:content) { should match(/^api_fqdn ".+"$/) }
end

describe file('/etc/hosts') do
  its(:content) { should match(/127.0.0.1 chef-server-tk.example.com/) }
end

describe command('chef-server-ctl test') do
  its(:exit_status) { should eq 0 }
end

describe command('chef-server-ctl org-list') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/sample/) }
end

describe command('chef-server-ctl list-user-keys exemplar') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/name: default\nexpired: false/) }
end
