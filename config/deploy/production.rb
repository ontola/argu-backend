# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{deploy@app.1.zones.argu.co}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

set :unicorn_pid, '/home/unicorn/pids/unicorn.pid'
set :unicorn_config_path, '/home/unicorn/unicorn.conf'

set :deploy_to, '/home/rails/argu'
set :environment, :production

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'app.1.zones.argu.co', user: 'deploy', roles: %w{app}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'service unicorn reload'
    end
  end
end
