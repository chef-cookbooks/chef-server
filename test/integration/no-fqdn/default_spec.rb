require 'resolv'

control 'chef-server-no-fqdn' do
  describe file('/etc/opscode/chef-server.rb') do
    its(:content) { should_not match(/^api_fqdn.*$/) }
  end

  describe command('chef-server-ctl test') do
    its(:exit_status) { should eq 0 }
  end
end
