#
# Cookbook Name:: rails-box-cookbook
# Spec:: default
#
# Refer to The MIT License (MIT)
#
# Copyright (c) 2015 Steven Praski

require 'spec_helper'
describe 'rails-box-cookbook::ruby' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end
    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
