# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{deploy@188.166.49.80}
#role :app_root, %w{root@188.166.49.80}
#role :web, %w{deploy@example.com}
#role :db,  %w{deploy@example.com}

set :unicorn_pid, '/home/unicorn/pids/unicorn.pid'
set :unicorn_config_path, '/home/unicorn/unicorn.conf'

set :deploy_to, '/home/rails/argu'
set :environment, :production
set :rails_env, :production

namespace :install do
  task :install do
    on roles(:app_root), in: :sequence, wait: 5 do
      execute 'curl -sL https://deb.nodesource.com/setup | sudo bash -'
      execute 'export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/X11/lib/pkgconfig'
      execute 'apt-get install -y build-essential lib-imagemagick git libvips-dev '\
                'libgsf-1-dev nodejs libxml2 zlib1g-dev libxslt libpq-dev'
      execute 'touch /home/rails/argu/shared/config/database.yml'
      execute 'touch /home/rails/argu/shared/config/secrets.yml'
      execute 'gem install bundle bundler'
    end
  end

  task :install_mutlimap do
    on roles(:app_root), in: :sequence, wait: 5 do
      execute 'cd /root'
      execute 'git clone https://github.com/doxavore/multimap --depth 1'
      execute 'gem build multimap.gemspec'
      execute 'gem install multimap-1.1.3.gem'
    end
  end
end

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'service unicorn reload'
    end
  end
end
