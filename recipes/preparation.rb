#
# Cookbook Name:: rails-box-cookbook
# Recipe:: preparation
#
# Refer to The MIT License (MIT)
#
# Copyright (c) 2015 Steven Praski
#

include_recipe 'base-box-cookbook::update'
include_recipe 'build-essential::default'
include_recipe 'rails-box-cookbook::ruby'
