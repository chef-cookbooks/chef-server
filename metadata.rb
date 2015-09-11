name 'chef-server'
version '4.1.0'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Installs and configures Chef Server 12'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://github.com/chef-cookbooks/chef-server' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/chef-server/issues' if respond_to?(:issues_url)

depends 'chef-ingredient', '>= 0.11.0'

supports 'centos'
supports 'ubuntu'
