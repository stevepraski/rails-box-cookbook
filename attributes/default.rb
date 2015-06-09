default['rails_box']['ruby']['global_version'] = '2.2.2'
default['rails_box']['ruby']['versions'] = ['2.2.2'] # last specified will be used by the app, if necessary

# FIXME: HOSTNAME?

# FIXME: manually remove default site?
default['nginx']['default_site_enabled'] = false
default['rails_box']['app_name'] = 'demo-app'
default['rails_box']['app_user'] = 'apps'
default['rails_box']['deploy']['revision'] = 'master'
default['rails_box']['deploy']['repository'] = 'https://github.com/westonplatter/example-rails-todolist.git'
default['rails_box']['listen_port'] = 80
default['rails_box']['ssl_key'] = nil
default['rails_box']['ssl_cert'] = nil
default['rails_app']['rack_env'] = 'development'

# unicorn
default['unicorn']['options'] = { 'tcp_nodelay' => true, 'backlog' => 100 }
default['unicorn']['worker_timeout'] = 60
default['unicorn']['preload_app'] = false
default['unicorn']['worker_processes'] = [node['cpu']['total'].to_i * 4, 8].min
default['unicorn']['before_fork'] = 'sleep 1'

# postgres client
case node['platform_family']
when 'debian' # tested only on ubuntu 12.04
  # because of an insane bug with postgres versioning, there is no way to (easily) get
  # a 9.3 version of libpg-dev when installing the client version 9.3
  # this is known issue in the postgres community
  postgres_ver = '9.4'
  default['postgresql']['version'] = postgres_ver
  default['postgresql']['enable_pgdg_apt'] = true
  default['postgresql']['client']['packages'] = ["postgresql-client-#{postgres_ver}", 'libpq-dev']
  default['postgresql']['server']['packages'] = ["postgresql-#{postgres_ver}"]
  default['postgresql']['contrib']['packages'] = ["postgresql-contrib-#{postgres_ver}"]
when 'rhel', 'chef-spec'
  postgres_ver = '9.3' # lastest version for centos is 9.3?
  postgres_ver_squish = postgres_ver.split('.').join
  default['postgresql']['version'] = postgres_ver
  default['postgresql']['enable_pgdg_yum'] = true
  # default['postgresql']['dir'] = "/var/lib/pgsql/#{node['postgresql']['version']}/data"
  default['postgresql']['client']['packages'] = ["postgresql#{postgres_ver_squish}", "postgresql#{postgres_ver_squish}-devel"]
  default['postgresql']['contrib']['packages'] = ["postgresql#{postgres_ver_squish}-contrib"]
else
  fail "Unsupported Platform Family: #{node['platform_family']}"
end
