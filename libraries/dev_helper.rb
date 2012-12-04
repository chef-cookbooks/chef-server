#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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

require 'mixlib/shellout'

module DevHelper

  def self.omnibus_path
    "/opt/chef-server/bin:/opt/chef-server/embedded/bin:/opt/chef-server/embedded/jre/bin"
  end

  def self.code_root
    "/opt/chef-server-dev/code"
  end

  def self.backup_root
    "/opt/chef-server-dev/backup"
  end

  def self.omnibus_service_root
    "/opt/chef-server/embedded/service"
  end

  class Project

    attr_accessor :name, :options
    attr_accessor :checkout_path, :omnibus_path
    attr_accessor :build_command, :preserved_paths

    def initialize(name, options)
      @name = name
      @options = options
      @checkout_path = File.join(DevHelper.code_root, name)
      @omnibus_path = options[:omnibus_path] || File.join(DevHelper.omnibus_service_root, name)
      @build_command = options[:build_command] || nil
      @preserved_paths = options[:preserved_paths] || []
    end

    def build_and_load
      shell_out("chef-server-ctl stop #{options[:service_name]}") if options.key?(:service_name)
      build
      link
      configure
      shell_out("chef-server-ctl start #{options[:service_name]}") if options.key?(:service_name)
    end

    private

    def build
      if build_command
        shell_out(options[:build_command], :cwd => checkout_path)
      end
    end

    def link
      if File.exists?(omnibus_path) && !File.symlink?(omnibus_path)
        release_path = options.key?(:release_path) ?
                          File.join(checkout_path, options[:release_path]) :
                          checkout_path
        FileUtils.mv(omnibus_path, DevHelper.backup_root)
        FileUtils.ln_s(release_path, omnibus_path)
      end
    end

    def configure
      preserved_paths.each do |path|
        backup_path = File.join(DevHelper.backup_root, name, path)
        dest_path = File.join(omnibus_path, path)
        if File.exists?(backup_path)
          FileUtils.mkdir_p(File.dirname(dest_path))
          FileUtils.cp_r(backup_path, dest_path, {:remove_destination => true,
                                                  :preserve => true})
        end
      end
    end

    def shell_out(command, options={})
      default_opts = {
        :environment => {'PATH' => "#{DevHelper.omnibus_path}:#{ENV['PATH']}"},
        :live_stream => STDOUT
      }
      c = Mixlib::ShellOut.new(command, default_opts.merge(options))
      c.run_command
      c.error!
    end
  end
end
