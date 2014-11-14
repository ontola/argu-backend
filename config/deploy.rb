# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'argu'
set :repo_url, 'git@bitbucket.org:arguweb/argu.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'
set :deploy_to, '/home/rails/argu'
set :scm, :git
set :environment, :production

set :ssh_options, {
      forward_agent: true,
      auth_methods: %w(publickey),
      port: 22
    }

set :log_level, :debug

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle public/system}

SSHKit.config.command_map[:rake]  = "bundle exec rake" #8
SSHKit.config.command_map[:rails] = "bundle exec rails"

set :keep_releases, 20

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :pty is false
# set :pty, true

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      #invoke 'unicorn:restart'
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
