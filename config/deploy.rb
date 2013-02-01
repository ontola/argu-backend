set :application, "alpha.argu.nl"

role :web, application                          # Your HTTP server, Apache/etc
role :app, application                          # This may be the same as your `Web` server
role :db,  application, :primary => true		# This is where Rails migrations will run

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :repository, "git@bitbucket.org:fletcher91/argu.git"
set :branch, "cap"

set :user, "deploy"
set :deploy_to, "/var/www/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do  
  task :symlink_shared do
  	#create symlinks for password files
  	run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  	run "ln -nfs #{shared_path}/config/ca-bundle.crt #{release_path}/config/ca-bundle.crt"
  	run "ln -nfs #{shared_path}/config/initializers/devise.rb #{release_path}/config/initializers/devise.rb"
  	run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
  	run "ln -nfs #{shared_path}/config/initializers/omniauth.rb #{release_path}/config/initializers/omniauth.rb"
  	run "ln -nfs #{shared_path}/config/cert #{release_path}/config/cert"
  end

  task :bundle do
  	require "bundler/capistrano"					# Update gems
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared', 'deploy:bundle', 'deploy:migrations', 'deploy:assets', 'deploy:restart'