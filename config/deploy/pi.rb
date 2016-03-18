# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{pi@194.171.10.64}

set :unicorn_pid, '/home/unicorn/pids/unicorn_staging.pid'
set :unicorn_config_path, '/home/unicorn/unicorn_staging.conf'

set :deploy_to, '/home/rails/argu_staging'
set :environment, :staging
set :branch, :develop

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '194.171.10.64', user: 'pi', roles: %w{app}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'service unicorn_staging reload'
    end
  end
end
