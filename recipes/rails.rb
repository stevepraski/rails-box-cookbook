#
# Cookbook Name:: rails-box-cookbook
# Recipe:: rails
#
# Refer to the MIT License (MIT)
#
# Copyright (c) 2015 Steven Praski
#

# basic request flow is: nginx -> unicorn -> rails

include_recipe 'runit::default'
include_recipe 'nginx::default'
include_recipe 'unicorn::default'
include_recipe 'postgresql::client'

# FIXME: git ssh clones will still fail due to lack of sshd identity generation
include_recipe 'ssh_known_hosts'
ssh_known_hosts_entry 'github.com'

# attribute and variable calculations ( to avoid the derived attribute problem )
app_user = node['rails_box']['app_user']
app_name = node['rails_box']['app_name']
app_user_dir = File.join('/home', app_user)
app_dir = File.join(app_user_dir, app_name)
app_root = File.join(app_dir, 'current', 'public')
app_working_dir = File.join(app_dir, 'current')
app_ruby = node['rails_box']['ruby']['versions'].last
socket = File.join(app_dir, '/shared/sockets/unicorn.sock')
server = "unix:#{socket}"
unicorn_conf = File.join('/etc/unicorn', app_name)
listen_port = node['rails_box']['listen_port']
deploy_shared_dirs = %w(assets log config pids system sockets)

group app_user do
  action :create
end

user app_user do
  gid app_user
  home File.join('/home', app_user)
  shell '/bin/bash'
  comment 'Application User'
  action :create
end

# let nginx in
directory app_user_dir do
  mode '0775'
end

# application directory scaffolding (should actually be done by deployment mechanism?)
deploy_shared_dirs.each do |path|
  directory File.join(app_dir, 'shared', path) do
    owner app_user
    group app_user
    mode '0775'
    recursive true
  end
end

# Nginx
# template taken with thanks from https://github.com/teohm/rackbox-cookbook
# NOTE: I've removed hostname
template File.join(node['nginx']['dir'], 'sites-available', app_name) do
  source 'nginx.conf.erb'
  mode '0644'
  owner 'root'
  group node['platform_family'] == 'freebsd' ? 'wheel' : 'root'
  variables(
    root_path: app_root,
    log_dir: node['nginx']['log_dir'],
    appname: app_name,
    servers: [server],
    listen_port: listen_port,
    ssl_key: node['rails_box']['ssl_key'],
    ssl_cert: node['rails_box']['ssl_cert']
  )
  notifies :restart, 'service[nginx]'
end

# Unicorn template
unicorn_config unicorn_conf do
  listen(node['unicorn']['port'] => node['unicorn']['options'])
  working_directory app_working_dir
  worker_timeout node['unicorn']['worker_timeout']
  preload_app node['unicorn']['preload_app']
  worker_processes node['unicorn']['worker_processes']
  before_fork node['unicorn']['before_fork']
end

# unicorn runit
runit_service app_name do
  run_template_name 'unicorn'
  log_template_name 'unicorn'
  cookbook 'rails-box-cookbook'
  options(
    user: app_user,
    group: app_user,
    rack_env: node['rails_app']['rack_env'],
    smells_like_rack: true,
    unicorn_config_file: unicorn_conf,
    working_directory: app_working_dir
  )
  restart_on_update false
end

# deployment
application app_name do
  owner app_user
  group app_user
  path app_dir
  revision node['rails_box']['deploy']['revision']
  repository node['rails_box']['deploy']['repository']
end

# workaround for missing .ruby-version
# FIXME: read from Gemfile directly?
file File.join(app_working_dir, '.ruby-version') do
  content app_ruby
  action :create_if_missing
end

execute 'pg gem dependacy' do
  user 'root'
  command "bundle config build.pg --with-pg-config=/usr/pgsql-#{node['postgresql']['version']}/bin/pg_config"
end

# FIXME: platform specific shell initiation is critical for rbenv shims to work:
# refer: https://github.com/sstephenson/rbenv/wiki/Unix-shell-initialization
# probably want to fix this and move to user creation, dumping a hard-link to the proper init file
shell_init_file =  node['platform_family'] == 'rhel' ? '.bash_profile' : '.bashrc'
shell_init_path = File.join(app_user_dir, shell_init_file)

# FIXME: ignores migrations, etc.
execute 'bundle with binary stubs' do
  user app_user
  command "source #{shell_init_path} && cd #{app_working_dir} && \
  bundle install --binstubs --deployment --without development test"
end

# FIXME: ignoring database configuration

# open a port
# FIXME: REFACTOR: more elegant to use prep-box-cookbook:firewall
# simple_iptables_rule 'rails' do
#   rule ["--proto tcp --dport #{listen_port}"]
#   jump 'ACCEPT'
# end

nginx_site app_name do
  notifies :reload, 'service[nginx]'
end
