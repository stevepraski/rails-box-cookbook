#
# Cookbook Name:: rails-box-cookbook
# Recipe:: ruby
#
# Refer to the MIT License (MIT)
#
# Copyright (c) 2015 Steven Praski
#

include_recipe 'rbenv::default'
include_recipe 'rbenv::ruby_build'

node['rails_box']['ruby']['versions'].each do |ruby_version|
  rbenv_ruby ruby_version do
    global(node['rails_box']['ruby']['global_version'] == ruby_version)
  end
  rbenv_gem 'bundler' do
    ruby_version ruby_version
  end
end
