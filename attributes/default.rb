default['rails_box']['ruby']['global_version'] = '2.2.2'
default['rails_box']['ruby']['versions'] = ['2.2.2'] # last specified will be used by the app, if necessary

# FIXME: HOSTNAME?

# FIXME: manually remove default site?
default['nginx']['default_site_enabled'] = false
default['rails_box']['app_name'] = 'demo-app'
default['rails_box']['app_user'] = 'apps'
default['rails_box']['deploy']['revision'] = 'master'
default['rails_box']['deploy']['repository'] = 'https://github.com/heroku/ruby-rails-unicorn-sample.git'
default['rails_box']['listen_port'] = 80
default['rails_box']['ssl_key'] = nil
default['rails_box']['ssl_cert'] = nil
default['rails_app']['rack_env'] = 'production'

# unicorn
default['unicorn']['listen_options'] = { 'tcp_nodelay' => true, 'backlog' => 100 }
default['unicorn']['worker_timeout'] = 60
default['unicorn']['preload_app'] = false
default['unicorn']['worker_processes'] = [node['cpu']['total'].to_i * 4, 8].min
default['unicorn']['before_fork'] = 'sleep 1'

# postgres client
default['postgresql']['version'] = '9.3' # lastest version for centos is 9.3?
default['postgresql']['enable_pgdg_yum'] = true
# default['postgresql']['enable_pgdg_apt'] = true
default['postgresql']['dir'] = "/var/lib/pgsql/#{node['postgresql']['version']}/data"
default['postgresql']['client']['packages'] = ['postgresql93', 'postgresql93-devel']
default['postgresql']['contrib']['packages'] = ['postgresql93-contrib']
