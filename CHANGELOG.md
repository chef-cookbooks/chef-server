# chef-server cookbook CHANGELOG

This file is used to list changes made in each version of the chef-server cookbook.

## 5.5.1 (2017-10-25)

- Update the bootstrap instructions in the readme to remove the old dependent cookbooks
- Don't fail if add-on version is not specified

## 5.5.0 (2017-10-23)

- Require Chef 12.7 or later as 12.5 and 12.6 had issues with custom resources
- Require Chef Ingredient >= 2.1.10 which is compatible with this cookbook once again
- Improve testing with spec cleanups and using dokken-images in Travis CI

## 5.4.0 (2017-04-12)

- Added the ability to specify the versions of each add-on to install so you can lock to specific versions

## 5.3.0 (2017-04-11)

- Convert testing to kitchen-dokken with inspec with a test recipe that looks more like the wrapper cookbook a user would use
- Convert lint / unit testing from Rake to Delivery local mode
- Remove the table of product names in the readme, which weren't up to date. Link to mixlib-install instead since that list is updated
- Update the license strings to be SPDX standard Apache-2.0

## 5.2.0 (2017-03-27)

- Add compat_resource to the readme instructions
- Pin chef-ingredient and require Chef 12.5+

## 5.1.0 (2016-09-16)
- Testing updates
- Require Chef 12.1 not 12.0

## v5.0.1 (2016-04-28)

As of Chef management console 2.3.0 the [Chef MLSA must be accepted when reconfiguring the product.](https://docs.chef.io/install_server.html) Chef ingredient added the [accept_license](https://github.com/chef-cookbooks/chef-ingredient/pull/101) property to provide a way to automate this. This fix adds the attribute ['chef-server']['accept_license']. The default value is _false_. Individuals must explicitly change the value to true in their environment. 

## v5.0.0 (2016-04-13)

### Breaking Changes:

This cookbook now requires chef-ingredient 0.18 or later. This switches the package source for chef-server packages to packages.chef.io, and also changes the names of the server add-ons as follows:

- chef-ha -> ha
- chef-sync -> sync
- push-server -> push-jobs-server

## v4.1.0 (2015-08-31)

- [#105](https://github.com/chef-cookbooks/chef-server): Move `fqdn_resolves` method to chef-ingredient cookbook.

## v4.0.0 (2015-06-30)

**Major version update, breaking changes ahead**

- 84: Add ability to set the package source with an attribute for local package installation
- 90: **Breaking** Use [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient). The breaking change is that of the configuration file. Users who are modifying the configuration with the `node['chef-server']['configuration']` attribute as a hash will need to convert it to a string. See the README for more detail.
- 93: Add a `topology` attribute. Finally you can use this cookbook for non-standalone installs.

## v3.1.1 (2015-04-09)

- various cleanup
- rubocop -a
- adding .kitchen.cloud.yml
- minor readability refactoring

## v3.1.0 (2015-03-16)

- Add a recipe and attribute to support installing addons. These are Chef premium features, see the README for more information about the `addons` recipe.

## v3.0.1 (2015-03-02)

- Issue #74, use :reconfigure action instead of notification so other configuration can happen after the Server is up within the same Chef run.

## v3.0.0 (2015-02-24)

**Major Version Update**

Version 3.0.0 supports Chef Server 12. For background and rationale, see [the mailing list post](http://lists.opscode.com/sympa/arc/chef/2015-02/msg00351.html). Changes are from commit [0f2d123](https://github.com/chef-cookbooks/chef-server/commit/0f2d123ad9ebb40ac18fdabdeee2d66735604bbe).

- Remove the omnitruck API client library and related attributes
- Use packagecloud repository for packages through the `chef_server_ingredient` resource
- Remove the `dev` recipe
- Remove the dependency on the git cookbook
- Remove the Vagrantfile - we use test-kitchen now
- Update the Berksfile accordingly
- Add ServerSpec tests

### Other changes

- Fixes #46/COOK-4691, use IP address as hostname. This is only recommended for testing purposes.

## v2.1.6 (2014-05-22)

- COOK-4660 - Adds a OS version and image updates to the testing harness

## v2.1.4 (2014-03-29)

- Dropping dependency on git

## v2.1.2 (2014-03-18)

- [COOK-4386] - 'package_options' attribute added

## v2.1.0 (2014-02-24)

- Updating test harness, adding amazon support to omnitruck library
- '[COOK-4176] - Ensure creation of `:file_cache_path`'
- '[COOK-4178] - update Bento boxes used in chef-server cookbook'

## v2.0.1

Documentation update to reflect Vagrant version dependency

## v2.0.0

- Complete re-write for Chef Server 11+. Chef Server is now installed
- using "fat" Omnibus package.

## v1.1.0

- [COOK-1637] - Directory creation in chef-server should be recursive
- [COOK-1638] - chef-server: Minor foodcritic fixups needed
- [COOK-1643] - Chef Server Cookbook Missing Erlang in Metadata Depends
- [COOK-1767] - use platform_family in chef-server cookbook

## v1.0.0

- [COOK-801] - add amazon linux
- [COOK-886] - use bin path consistently
- [COOK-1034] - expander bluepill doesn't have default value for node count

## v0.99.12

- [COOK-757] - compact all the views
- [COOK-969] - `server_name` and `server_aliases` as configurable attributes on `chef_server::nginx-proxy` and `chef_server::apache-proxy`
