#
# Cookbook:: chef-server
# Recipe:: addons
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
node['chef-server']['addons'].each do |addon, ver|
  chef_ingredient addon do
    accept_license node['chef-server']['accept_license']
    notifies :reconfigure, "chef_ingredient[#{addon}]"
    version ver unless ver.nil?
  end
end
