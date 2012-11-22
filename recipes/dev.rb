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

include_recipe "git"

repos = {
  'chef_authn' => {},
  'chef_certgen' => {},
  'chef_db' => {},
  'chef_index' => {},
  'chef_objects' => {},
  'chef_wm' => {},
  'erchef' => {
    :service_name => 'erchef',
    :preserved_paths => ["etc/app.config",
                         "log",
                         "bin/erchef"],
    :build_command => "rebar get-deps && make clean relclean devrel",
    :release_path => "rel/erchef"
  },
  'chef-server-webui' => {
    :service_name => 'chef-server-webui',
    :preserved_paths => ["config/environments/chefserver.rb",
                         "tmp",
                         "config/initializers/secret_token.rb",
                         "config/initializers/session_store.rb",
                         "config.ru"],
    :build_command => "bundle install --deployment --without development"
  },
  'omnibus-chef' => {
    :omnibus_path => "/opt/chef-server/embedded/cookbooks",
    :release_path => "files/chef-server-cookbooks"
  },
  'chef-pedant' => {
    :build_command => "bundle install"
  }
}

[ DevHelper.code_root, DevHelper.backup_root].each do |dir|
  directory dir do
    owner "root"
    group "root"
    recursive true
    action :create
  end
end

repos.each do |project, options|

  github_name = options.key?(:github_name) ? options[:github_name] : project

  git ::File.join(DevHelper.code_root, project) do
    repository "git://github.com/opscode/#{github_name}"
    reference "master"
    action :checkout
  end

  ruby_block "build and load #{project}" do
    block do
      p = DevHelper::Project.new(project, options)
      p.build_and_load
    end
  end
end

# Ensure the /opt/chef-server bin/ dirs is first in our PATH
file "/etc/profile.d/omnibus-embedded.sh" do
  content "export PATH=\"#{DevHelper.omnibus_path}:$PATH\""
  action :create
end
