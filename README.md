chef-server README
==================

This cookbook configures a system to be a *standalone* Chef Server. It
will install the appropriate platform-specific chef-server Omnibus
package from Package Cloud and perform the initial configuration.


It is not in the scope of this cookbook to handle more complex Chef
Server topologies like 'tiered' or 'ha'. Nor is it in the scope of
this cookbook to install and configure premium features or other
add-ons. For clustered Chef Server deployments, see
[chef-server-cluster](https://github.com/opscode-cookbooks/chef-server-cluster).
For primitives for installing `chef-server-core` or other Chef Server
add-ons, see
[chef-server-ingredient](https://supermarket.chef.io/cookbooks/chef-server-ingredient).


It is also not in the scope of this cookbook to handle older versions
of Chef Server, such as 11 or 10. For Chef Server 11, see version
2.1.x of this cookbook on Supermarket, or the `chef11` branch of this
repository.


Requirements
============

This cookbook is tested with  Chef (client) 12. It may work with or
without modification on earlier versions of Chef, but Chef 12 is
recommended.

## Cookbooks

* chef-server-ingredient cookbook

## Platform

This cookbook is tested on the following platforms using the
[Test Kitchen](http://kitchen.ci) `.kitchen.yml` in the repository.

- RHEL/CentOS 5 64-bit
- RHEL/CentOS 6 64-bit
- Ubuntu 10.04, 10.10 64-bit
- Ubuntu 11.04, 11.10 64-bit
- Ubuntu 12.04, 12.10 64-bit
- Ubuntu 14.04, 14.10 64-bit

Unlisted platforms in the same family, of similar or equivalent
versions may work with or without modification to this cookbook. For a
list of supported platforms for Chef Server, see the
[Chef documentation](https://docs.chef.io/supported_platforms.html#chef-server-title).


Attributes
==========

The attributes used by this cookbook are under the `chef-server` name
space.

Attribute        | Description |Type | Default
-----------------|-------------|-----|--------
api_fqdn         | Fully qualified domain name that you want to use for accessing the Web UI and API. If set to `nil` or empty string (`""`), the IP address will be used as hostname. | String | node['fqdn']
configuration    | Configuration to pass down to the underlying server config file (i.e. `/etc/chef-server/chef-server.rb`). | String | ""
version          | Chef Server version to install. If `nil`, the latest version is installed | String | nil
addons           | Array of addon packages (you need to add the addons recipe to the run list for the addons to be installed) | Array | Array.new

Previous versions of this cookbook had several other attributes used
to control the version of the Chef Server package to install. This is
deprecated.

Previous versions of this cookbook used `configuration` as a Hash. This is now deprecated and the configuration should be specified as a String. This must include newlines for each of the configuration items.

See https://docs.chef.io/config_rb_server.html for configuration options for Chef Server and below table for addons:

Addon | Product Name  | Config Documentation
------|---------------|---------------------
manage | Management Console | https://docs.chef.io/config_rb_manage.html
chef-ha | Chef Server High Availability | https://docs.chef.io/server_high_availability.html
chef-sync	| Chef Server Replication | https://docs.chef.io/config_rb_chef_sync.html
reporting | Chef Server Reporting | No separate config.
push-server | Chef Push Server | https://docs.chef.io/config_rb_push_jobs_server.html
supermarket | Supermarket | https://docs.chef.io/config_rb_supermarket.html

Recipes
=======

This section describes the recipes in the cookbook and how to use them
in your environment.


## default

This recipe:

- Installs the appropriate platform-specific chef-server Omnibus
  package from our Package Cloud
  [repository](https://packagecloud.io/chef/stable)
- Creates the initial `/etc/chef-server/chef-server.rb` file.
- Performs initial system configuration via `chef-server-ctl
  reconfigure`.
- Updates the `/etc/hosts` file with the `api_fqdn` if that FQDN
  cannot be resolved.

## addons

Chef addons are premium features that can be installed on the Chef
Server with the
[appropriate license](https://www.chef.io/chef/#plans-and-pricing). If
there are < 25 nodes managed, or a paid subscription license, addons
can be installed.

This recipe iterates through the `node['chef-server']['addons']`
attribute and installs and reconfigures all the packages listed.


Install Methods
===============

## Bootstrap Chef (server) with Chef (solo)

The easiest way to get a Chef Server up and running is to install
chef-solo (via the chef-client Omnibus packages) and bootstrap the
system using this cookbook:

    # install chef-solo
    curl -L https://www.chef.io/chef/install.sh | sudo bash
    # create required bootstrap dirs/files
    sudo mkdir -p /var/chef/cache /var/chef/cookbooks
    # pull down this chef-server cookbook
    wget -qO- https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks
    # pull down dependency cookbooks
    for dep in chef-ingredient yum-chef yum apt-chef apt packagecloud
    do
      wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | sudo tar xvzC /var/chef/cookbooks
    done
    # GO GO GO!!!
    sudo chef-solo -o 'recipe[chef-server::default]'

Be sure to download and untar the `chef-ingredient`, `yum-chef`, `yum`, `apt-chef`, `apt`, and `packagecloud` cookbooks. They're dependencies of this cookbook.

If you need more control over the final configuration of your Chef Server instance you can create a JSON attributes file and set underlying configuration via the `node['chef-server']['configuration']` attribute. See the [attributes/default.rb](attributes/default.rb)

Then pass this file to the initial chef-solo command:

    chef-solo -j /tmp/dna.json

### Configuring Chef Server

You can read all about Chef Server's configuration options on the [Chef Documentation site](http://docs.chef.io/server/config_rb_server.html).

Specify configuration using the `node['chef-server']['configuration']` attribute as a string. Each configuration item should be separated by newlines. This string will be rendered exactly as written in the configuration file, `/etc/opscode/chef-server.rb`. For example, if we want to change the notification email, we could do this in a wrapper cookbook:

```ruby
node.default['chef-server']['configuration'] = "notification_email 'chef-server@example.com'"
```

Or in a `dna.json` file:

```json
{
  "chef-server": {
    "configuration": "notification_email 'chef-server@example.com'"
  }
}
```

Or, for multiple configuration settings, such as the notification email and the cache size for nginx, this uses a heredoc:

```ruby
node.default['chef-server']['configuration'] = <<-EOS
notification_email 'chef-server@example.com'
nginx['cache_max_size'] = '3500m'
EOS
```

In a `dna.json` file, we need to insert a `\n` newline character.

```json
{
  "chef-server": {
    "configuration": "notification_email 'chef-server@example.com'\nnginx['cache_max_size'] = '3500m'"
  }
}
```

### Applying configuration changes

The `chef-server-ctl` command is the administrative interface to the Chef Server. It has its own [documentation](https://docs.chef.io/ctl_chef_server.html). Various administrative functions provided by `chef-server-ctl` are not in the scope of this cookbook. Special/customized needs should be managed in your own cookbook.

As this cookbook uses the [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient), its resources can be used to manage the Chef Server installation. The default recipe in this cookbook exposes `chef_ingredient[chef-server]` as a resource that can be sent a `:reconfigure` action from your own cookbooks. The `omnibus_service` resource can be used to manage the underlying services for the Chef Server. See the [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient#readme) for more information.

# License and Authors

* Author: Seth Chisamore <schisamo@chef.io>
* Author: Joshua Timberman <joshua@chef.io>
* Copyright 2012-2015, Chef Software, Inc

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
```
