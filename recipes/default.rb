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

cache_path = Chef::Config[:file_cache_path]

# see helpers.rb
ruby_block 'ensure node can resolve API FQDN' do
  extend ChefServerCoobook::Helpers
  block { repair_api_fqdn }
  only_if { api_fqdn_node_attr }
  not_if { api_fqdn_resolves }
end

chef_server_ingredient 'chef-server-core' do
  version node['chef-server']['version']
  action :install
end

file "#{cache_path}/chef-server-core.firstrun" do
  action :create
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]', :immediately
end

directory '/etc/opscode' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# create the initial chef-server config file
template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
  owner 'root'
  group 'root'
  action :create
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]', :immediately
end
