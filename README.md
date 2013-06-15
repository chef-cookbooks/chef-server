Chef Server
===========

This cookbook configures a system to be a Chef Server. It will install
the appropriate platform-specific chef-server Omnibus package and
perform the initial configuration of Chef Server.

## Omnibus-based Chef-Server Overview

To understand how this cookbook works it is useful to understand how a
Chef Server instance installed via Omnibus packages behaves.

### Know an Omnibus

Omnibus allows you to build self-contained full-stack software
packages. We use Omnibus to to distribute the Chef Server bundled with
its dependencies such as Erlang, Ruby, PostgreSQL, RabbitMQ, and
Nginx. The result is a single package that can be installed on the
target system and configured.

Omnibus packages separate the installation step from the configuration
step. After an Omnibus package is installed, a configuration step must
be run before the installed system can be used. In particular, this
approach makes handling upgrades easier.

### Configuring Chef Server

Chef Server is configured through the
`/etc/chef-server/chef-server.rb` file.  Standalone single-server
configurations do not require custom configuration and can use the
default values for everything.

You can read all about Chef Server's
[configuration options](http://docs.opscode.com/config_rb_chef_server.html).

### Applying configuration changes

The `chef-server-ctl reconfigure` command reads the
`/etc/chef-server/chef-server.rb` file and applies the specified
configuration to the system. Any time you make a change to your
configuration, you need to run `chef-server-ctl reconfigure` to apply
it.

### chef-server-ctl

Omnibus-based Chef Server installs have a command line utility,
`chef-server-ctl`, which is used to operate the Chef Server. For
example, you can use `chef-server-ctl` to start and stop individual
services, reconfigure the entire server, and tail server log files.

`chef-server-ctl` commands are documented below:

    $ chef-server-ctl COMMAND

command    | Action
-----------|---------
help       | Print a list of all the available chef-server-ctl commands.
status     | Shows the status of the Chef Server services.
start      | Start all the enabled Chef Server services.
stop       | Stop all the enabled Chef Server services.
restart    | Restart all the enabled chef server services.
tail       | Follow the Chef Server logs for all services.
test       | Executes, chef-pedant, the integration test suite against the Chef Server installation. By default only a subset of tests are run, add the `--all` flag to run the full test suite.

The status, start, stop, restart, and tail commands can optionally be
applied to a single service by adding the service name to the end of
the command line. For example, to get the status of the erchef
component of Chef Server, you can run:

    chef-server-ctl status erchef


REQUIREMENTS
============

Chef 10

Platform
--------

Chef Server Omnibus packages are available for the following platforms:

* CentOS 5 64-bit
* CentOS 6 64-bit
* Ubuntu 10.04, 10.10 64-bit
* Ubuntu 11.04, 11.10 64-bit
* Ubuntu 12.04, 12.10 64-bit

ATTRIBUTES
==========

The attributes used by this cookbook are under the `chef-server` name space.

Attribute        | Description |Type | Default
-----------------|-------------|-----|--------
api_fqdn         | Fully qualified domain name that you want to use for accessing the Web UI and API. | String | node['fqdn']
configuration    | Configuration values to pass down to the underlying server config file (i.e. `/etc/chef-server/chef-server.rb`). | Hash | Hash.new
package_file     | Location of the Omnibus package to install. This should not be set if you wish to pull the packages from the Omnitruck S3 bucket. | String | nil
package_checksum | SHA256 checksum of package referenced by `package_file`. | String | nil
version          | Chef Server version to install. This value is ignored if `package_file` is set. | String | :latest
prereleases      | Indicates prerelease builds should be downloaded from Omnitruck. Prerelease builds come out in the weeks leading up to a major release. Prereleases offer an early preview of the next upcoming stable release and are intended for testers and advanced users. This value is ignored if `package_file` is set. | Boolean | false
nightlies        | Indicates nightly builds should be downloaded from Omnitruck. Nightly builds of chef-server usually come out every night, but may be less frequent if there are no changes to the code, or the CI infrastructure is unable to create a build that day. The nightly builds are intended for testing only. This value is ignored if `package_file` is set. | Boolean | false

RECIPES
========

This section describes the recipes in the cookbook and how to use them
in your environment.

default
-------

This recipe:

* Installs the appropriate platform-specific chef-server Omnibus package.
* Creates the initial `/etc/chef-server/chef-server.rb` file.
* Performs initial system configuration via `chef-server-ctl reconfigure`.

Omnibus package selection is done based on the following logic:

1. If a value has been provided, the chef-server Omnibus package is
   fetched from `node['chef-server']['package_file']`
2. If `node['chef-server']['package_file']` is unset (ie nil or empty
   string), the candidate package is retrieved from the Omnitruck REST
   API based on `node['chef-server']['version']` AND the node
   platform, platform_version and architecture. By default the latest package
   is installed. If you would like to download pre-release or nightly builds
   set appropriate attribute to `true`.

dev
---

This recipe converts a Chef Server installation into development mode
for easy hacking on the underlying server components. This recipe should
not be run on a production server.

This recipe will place checkouts for all of Chef Server's main
software components at `/opt/chef-server-dev/code`. These component
checkouts will also be symlinked into the underlying Chef Server
installation.  Changes made to component code will be reflected in the
running Chef Server instance (most often only after a restart of the
given service).

INSTALL METHODS
===============

## Bootstrap Chef (server) with Chef (solo)

The easiest way to get a Chef Server up and running is to install
chef-solo (via the chef-client Omnibus packages) and bootstrap the
system using this cookbook:

    # install chef-solo
    curl -L https://www.opscode.com/chef/install.sh | sudo bash
    # create required bootstrap dirs/files
    mkdir -p /var/chef/cache /var/chef/cookbooks/chef-server
    # pull down this chef-server cookbook
    wget -qO- https://github.com/opscode-cookbooks/chef-server/archive/master.tar.gz | tar xvzC /var/chef/cookbooks/chef-server --strip-components=1
    # GO GO GO!!!
    chef-solo -o 'recipe[chef-server::default]'

If you need more control over the final configuration of your Chef
Server instance you can create a JSON attributes file and set
underlying configuration via the
`node['chef-server']['configuration']` attribute. For example, you can
disable the webui with the following configuration:

    echo '{
      "chef-server": {
        "configuration": {
          "chef_server_webui": {
            "enable": false
          }
        }
      },
      "run_list": [ "recipe[chef-server::default]" ]
    }' > /tmp/no-webui.json

You would then pass this file to the initial chef-solo command:

    chef-solo -j /tmp/no-webui.json

## Demo Chef Server with Vagrant and Berkshelf

We <3 the wonderful open-source tools
[Berkshelf](http://berkshelf.com/) and
[Vagrant](http://vagrantup.com/). You can take Chef Server for a spin
using the Berksfile and Vagrantfile that ship alongside this cookbook.
The only requirements for standing up a virtualized Chef Server are:

* VirtualBox - native packages exist for most platforms and can be downloaded
from the [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads).
* Vagrant 1.1+ - native packages exist for most platforms and can be downloaded
from the [Vagrant downloads page](http://downloads.vagrantup.com/).

The [vagrant-berkshelf](https://github.com/RiotGames/vagrant-berkshelf) and
[vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus) Vagrant plugins
are also required and can be installed easily with the following commands:

```shell
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
```

Once the pre-requisites are installed you can start the virtualized environment
with the following command:

```shell
$ vagrant up
```

Although things have only been tested with Vagrant's `virtualbox` provider
everything should work with other providers like `vmware_fusion` or `ec2`.

You can easily SSH into the running VM using the `vagrant ssh` command.
The VM can easily be stopped and deleted with the `vagrant destroy`
command. Please see the official
[Vagrant documentation](http://vagrantup.com/v1/docs/commands.html) for a more
in depth explanation of available commands.

The running Chef-Server components are accessible from the host machine
using the following URLs:

* Web UI: https://33.33.33.50/ (Note: Attempts to hit via straight http will be
redirected to the Vagrant guest's internal hostname)
* Version Manifest: https://33.33.33.50/version
* Chef Server API (routing requires `X-OPS-USERID` HTTP header being properly
set): https://33.33.33.50/

*Note: It can be helpful to use the host workstation's /etc/hosts file to map
33.33.33.50 to chef-server-berkshelf.*

## Contribute to and Hack on Chef Server (including Erchef)

This cookbook ships with a recipe named `dev` that will take any Chef
Server instance and flip it into development mode. If you want to use
the Vagrant-based environment referenced above, edit the `chef.run_list`
value in the `Vagrantfile` to include an additional
`recipe[chef-server::dev]` run list item.


LICENSE AND AUTHORS
===================

* Author: Seth Chisamore <schisamo@opscode.com>

Copyright 2012, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
