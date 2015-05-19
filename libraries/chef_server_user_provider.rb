require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class ChefServerUser < Chef::Provider::LWRPBase

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        execute 'create user' do
          command <<-EOM.gsub(/\s+/, ' ').strip!
            chef-server-ctl user-create #{new_resource.username}
            #{new_resource.firstname}
            #{new_resource.lastname}
            #{new_resource.email}
            #{new_resource.password}
            -f #{new_resource.private_key_path}
          EOM
          not_if "chef-server-ctl user-list | grep -w #{new_resource.username}"
        end
      end

      action :delete do
        # delete user
      end
    end
  end
end