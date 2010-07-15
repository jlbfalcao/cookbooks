#
# Cookbook Name:: activemq
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node[:activemq][:java] == "sun"
  include_recipe 'java_sun'
else
  include_recipe 'java'
end

version = node[:activemq][:version]
mirror = node[:activemq][:mirror]

unless File.exists?("/opt/apache-activemq-#{version}/bin/activemq")
  remote_file "/tmp/apache-activemq-#{version}-bin.tar.gz" do
    source "#{mirror}/apache/activemq/apache-activemq/#{version}/apache-activemq-#{version}-bin.tar.gz"
    mode "0644"
  end

  execute "tar zxf /tmp/apache-activemq-#{version}-bin.tar.gz" do
    cwd "/opt"
  end
end

# add link /opt/apache-activemq
link "/opt/activemq" do
  to "/opt/apache-activemq-#{version}"
end

group "activemq"

user "activemq" do
  action :create
  gid "activemq"
end

execute "chown-activemq-user" do
  command %Q{
    chown -R activemq.activemq /opt/apache-activemq-#{version}
  }
end

file "/opt/apache-activemq-#{version}/bin/activemq" do
  owner "root"
  group "root"
  mode "0755"
end

remote_file "/etc/init.d/activemq" do
  source "activemq"
  owner "root"
  group "root"
  mode 0755
end

if node[:activemq][:init_style] == "runit"
  runit_service "activemq"
else
  # init service
  service "activemq" do
    supports :status => true, :restart => true, :reload => true
    action :nothing
  end
end
