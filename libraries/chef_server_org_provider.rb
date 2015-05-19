require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class ChefServerOrg < Chef::Provider::LWRPBase

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        execute 'create org' do
          command <<-EOM.gsub(/\s+/, ' ').strip!
            chef-server-ctl org-create #{new_resource.org_name}
            #{new_resource.org_long_name}
            -f #{new_resource.org_private_key_path}
          EOM
          not_if "chef-server-ctl org-list | grep -w #{new_resource.org_name}"
        end
      end

      action :delete do
        # delete org
      end

      action :add_admin do
        new_resource.admins.each do |admin|
          execute 'add users to org' do
            command <<-EOM.gsub(/\s+/, ' ').strip!
              chef-server-ctl org-user-add #{new_resource.org_name} #{admin}
              --admin
            EOM
            # not_if "chef-server-ctl org-list | grep -w #{new_resource.org_name}"
          end
        end
      end
    end
  end
end