chef_server_user 'testuser' do
  firstname 'Test'
  lastname 'User'
  email 'testuser@example.com'
  password 'testuser'
  private_key_path '/tmp/testuser.pem'
  action :create
end

chef_server_org 'example' do
  org_long_name 'Example Organization'
  org_private_key_path '/tmp/example-validator.pem'
  action :create
end

chef_server_org 'example' do
  admins %w{ testuser }
  action :add_admin
end