#
# Cookbook:: chef-server
# Recipe:: default
#
# Copyright:: 2015-2019, Chef Software, Inc.
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

ruby_block 'ensure node can resolve API FQDN' do
  extend ChefServerCookbook::Helpers
  block { repair_api_fqdn }
  only_if { api_fqdn_available? }
  not_if { api_fqdn_resolves? }
end

chef_ingredient 'chef-server' do
  extend ChefServerCookbook::Helpers
  version node['chef-server']['version'] unless node['chef-server']['version'].nil?
  package_source node['chef-server']['package_source']
  accept_license node['chef-server']['accept_license']
  config <<-EOS
topology "#{node['chef-server']['topology']}"
#{"api_fqdn \"#{node['chef-server']['api_fqdn']}\"" if api_fqdn_available?}
#{node['chef-server']['configuration']}
  EOS
  action :install
end

file "#{cache_path}/chef-server-core.firstrun" do
  action :create
end

ingredient_config 'chef-server' do
  notifies :reconfigure, 'chef_ingredient[chef-server]', :immediately
end
