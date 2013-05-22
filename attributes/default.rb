#
# Cookbook Name:: chef-server
# Attributes:: default
#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

default['chef-server']['version'] = :latest
default['chef-server']['prereleases'] = false
default['chef-server']['nightlies'] = false
default['chef-server']['package_file'] = nil
default['chef-server']['package_checksum'] = nil
default['chef-server']['api_fqdn'] = node['fqdn']

#
# Chef Server Tunables
#
# For a complete list see:
# https://github.com/opscode/omnibus-chef-server/blob/master/files/chef-server-cookbooks/chef-server/attributes/default.rb
#
# Example:
#
# In a recipe:
#
#     node.override['chef-server']['configuration']['nginx']['ssl_port'] = 4433
#
# In a role:
#
#     override_attributes(
#       'chef-server' => {
#         'configuration' => {
#           'nginx' => {
#             'ssl_port' => 4433
#           }
#         }
#       }
#     )
#
default['chef-server']['configuration'] = Hash.new
