
set :application, 'argu'
set :repo_url, 'git@bitbucket.org:arguweb/argu.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'
set :scm, :git

set :ssh_options,
    forward_agent: true,
    auth_methods: %w(publickey),
    port: 22

set :log_level, :debug

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle public/system}

SSHKit.config.command_map[:rake]  = 'bundle exec rake' # 8
SSHKit.config.command_map[:rails] = 'bundle exec rails'

set :keep_releases, 5

set :assets_roles, [:web, :app]

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :pty is false
# set :pty, true

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do
  desc 'Update build number file'
  task :update_build_number do
    on roles(:all) do
      execute :echo,
              %("BUILD='#{ENV['SEMAPHORE_BUILD_NUMBER'] || '0'}' unless defined?(::BUILD)"),
              '>',
              "#{current_path}/config/initializers/build.rb"
    end
  end

  desc 'Links the assets directory of staging in the public '\
         'folder of production to make apache serve staging assets safely'
  task :link_staging_assets do
    on roles(:all) do
      execute :ln, '-s /home/rails/argu_staging/current/public/ '\
                     '/home/rails/argu/current/public/staging' # @safe kernelmethod
    end
  end

  desc 'Install npm modules'
  task :npm_install do
    on roles(:web, :app) do
      within release_path do
        execute :npm, 'install'
      end
    end
  end

  desc 'Compile browserify bundles'
  task :compile_bundles do
    on roles(:web, :app) do
      within release_path do
        execute :npm, :run, 'build:production'
      end
    end
  end

  before :compile_bundles, :npm_install
  before 'deploy:compile_assets', :compile_bundles
  after :updated, :compile_assets
  after :publishing, :update_build_number
  after :publishing, :link_staging_assets
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
