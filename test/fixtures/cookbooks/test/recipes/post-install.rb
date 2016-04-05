execute 'create-admin-user' do
  command 'chef-server-ctl user-create exemplar Example User exemplar@example.com dontusethisforreal --filename /tmp/exemplar.key'
  not_if 'chef-server-ctl user-list | grep "exemplar"'
end

execute 'create-organization' do
  command 'chef-server-ctl org-create sample "Sample Size" --association_user exemplar --filename /tmp/exemplar.key'
  not_if 'chef-server-ctl org-list | grep "sample"'
end
