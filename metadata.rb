name 'chef-server'
version '5.5.2'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache-2.0'
description 'Installs and configures Chef Server 12'
depends 'chef-ingredient', '>= 2.1.10'

supports 'redhat'
supports 'centos'
supports 'ubuntu'

source_url 'https://github.com/chef-cookbooks/chef-server'
issues_url 'https://github.com/chef-cookbooks/chef-server/issues'
chef_version '>= 12.7' if respond_to?(:chef_version)
