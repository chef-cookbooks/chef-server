#
# Copyright:: Copyright (c) 2012-2015 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'resolv'

chef_server_ingredient 'chef-server-core' do
  version node['chef-server']['version']
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
end

directory '/etc/opscode' do
  recursive true
end

# create the initial chef-server config file
template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
  owner 'root'
  group 'root'
  action :create
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
end

ruby_block 'ensure node can resolve API FQDN' do
  block do
    fe = Chef::Util::FileEdit.new('/etc/hosts')
    fe.insert_line_if_no_match(/#{node['chef-server']['api_fqdn']}/,
      "127.0.0.1 #{node['chef-server']['api_fqdn']}")
    fe.write_file
  end
  not_if { node['chef-server']['api_fqdn'].nil? || node['chef-server']['api_fqdn'].empty? }
  not_if { Resolv.getaddress(node['chef-server']['api_fqdn']) rescue false } # host resolves
end
