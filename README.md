# chef-server cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/chef-server.svg?branch=master)](http://travis-ci.org/chef-cookbooks/chef-server) [![Cookbook Version](https://img.shields.io/cookbook/v/chef-server.svg)](https://supermarket.chef.io/cookbooks/chef-server)

This cookbook configures a system to be a _standalone_ Chef 12+ Server. It will install the appropriate platform-specific chef-server Omnibus package from Package Cloud and perform the initial configuration.

It is not in the scope of this cookbook to handle more complex Chef Server topologies like 'tiered' or 'ha'. Nor is it in the scope of this cookbook to install and configure premium features or other add-ons. For clustered Chef Server deployments, see [chef-server-cluster](https://github.com/chef-cookbooks/chef-server-cluster). For primitives for installing `chef-server-core` or other Chef Server add-ons, see [chef-ingredient](https://supermarket.chef.io/cookbooks/chef-ingredient).

## Requirements

### Platforms

- RHEL 6+
- Ubuntu 14.04+


### Chef

- Chef 12.7+

### Cookbooks

- chef-ingredient >= 2.1.10

## Attributes

The attributes used by this cookbook are under the `chef-server` name space.

Attribute      | Description                                                                                                                                                         | Type    | Default
-------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | ------------
api_fqdn       | Fully qualified domain name that you want to use for accessing the Web UI and API. If set to `nil` or empty string (`""`), the IP address will be used as hostname. | String  | node['fqdn']
configuration  | Configuration to pass down to the underlying server config file (i.e. `/etc/chef-server/chef-server.rb`).                                                           | String  | ""
version        | Chef Server version to install. If `nil`, the latest version is installed                                                                                           | String  | nil
addons         | Array of addon packages, or Hash if you want to lock addon version Example: {package1:'1.2.3'} (you need to add the addons recipe to the run list for the addons to be installed) | Array  | []
accept_license | A boolean value that specifies if license should be accepted if it is asked for during reconfigure.                                                                 | Boolean | false

Previous versions of this cookbook had several other attributes used to control the version of the Chef Server package to install. This is deprecated.

Previous versions of this cookbook used `configuration` as a Hash. This is now deprecated and the configuration should be specified as a String. This must include newlines for each of the configuration items.

See <https://docs.chef.io/config_rb_server.html> for configuration options for Chef Server. For a complete list of product names for use in the add-ons attribute see <https://github.com/chef/mixlib-install/blob/master/PRODUCT_MATRIX.md>

## Recipes

This section describes the recipes in the cookbook and how to use them in your environment.

### default

This recipe:

- Installs the appropriate platform-specific chef-server Omnibus package from our Package Cloud [repository](https://packagecloud.io/chef/stable)
- Creates the initial `/etc/chef-server/chef-server.rb` file.
- Performs initial system configuration via `chef-server-ctl reconfigure`.
- Updates the `/etc/hosts` file with the `api_fqdn` if that FQDN cannot be resolved.

### addons

Chef addons are premium features that can be installed on the Chef Server with the [appropriate license](https://www.chef.io/chef/#plans-and-pricing). If there are under 25 nodes managed, or a paid subscription license, addons can be installed.

This recipe iterates through the `node['chef-server']['addons']` attribute and installs and reconfigures all the packages listed.  
_Note_: When multiple add-ons are installed, and one of them has version locked, either lock versions of all packages (best practice) or set version to `nil`
Example:  
default['chef-server']['addons'] = {'chef-manage' => '2.5.0', reporting: nil}

## Install Methods

### Bootstrap Chef (server) with Chef (solo)

The easiest way to get a Chef Server up and running is to install chef-solo (via the chef-client Omnibus packages) and bootstrap the system using this cookbook:

```
# install chef-solo
curl -L https://www.chef.io/chef/install.sh | sudo bash
# create required bootstrap dirs/files
sudo mkdir -p /var/chef/cache /var/chef/cookbooks
# pull down this chef-server cookbook
wget -qO- https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks
# pull down dependency cookbooks
for dep in chef-ingredient
do
  wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | sudo tar xvzC /var/chef/cookbooks
done
# GO GO GO!!!
sudo chef-solo -o 'recipe[chef-server::default]'
```

If you need more control over the final configuration of your Chef Server instance you can create a JSON attributes file and set underlying configuration via the `node['chef-server']['configuration']` attribute. See the [attributes file](attributes/default.rb).

Then pass this file to the initial chef-solo command:

```
chef-solo -j /tmp/dna.json
```

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

### Chef Proprietary Product Licensings

If on convergence you are observing an error in the form of:

```
             ================================================================================
             Error executing action `run` on resource 'execute[chef-manage-reconfigure]'
             ================================================================================

             Mixlib::ShellOut::ShellCommandFailed
             ------------------------------------
             Expected process to exit with [0], but received '1'
             ---- Begin output of chef-manage-ctl reconfigure ----
             STDOUT: To use this software, you must agree to the terms of the software license agreement.
             Please view and accept the software license agreement, or pass --accept-license.
             STDERR:
             ---- End output of chef-manage-ctl reconfigure ----
             Ran chef-manage-ctl reconfigure returned 1
```

when using proprietary Chef products, you will need to make sure to accept the Chef Master License and Services Agreement (Chef MSLA).

Proprietary Chef products—such as Chef Compliance, Chef Delivery, Chef Analytics, Reporting, and the Chef Management Console—are governed by the Chef MLSA. [The Chef MLSA must be accepted when installing or reconfiguring the product](https://docs.chef.io/chef_license.html). Chef ingredient added the [accept_license](https://github.com/chef-cookbooks/chef-ingredient/pull/101) property to provide a way to automate this. This fix adds the attribute ['chef-server']['accept_license']. The default value is _false_. Individuals must explicitly change the value to true in their environment to accept the license. Make sure you set the node attribute ['chef-server']['accept_license'] = true to resolve this error.

## License and Authors

- Author: Seth Chisamore [schisamo@chef.io](mailto:schisamo@chef.io)
- Author: Joshua Timberman [joshua@chef.io](mailto:joshua@chef.io)
- Copyright 2012-2016, Chef Software, Inc

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
