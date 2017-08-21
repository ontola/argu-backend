# frozen_string_literal: true
namespace :db do
  desc 'Loads the seed data from the filename provided in the env SEED'
  namespace :seed do
    task :single do
      filename = Dir[File.join(Rails.root, 'db', 'seeds', "#{ENV['SEED']}.seeds.rb")][0]
      puts "Seeding #{filename}..."
      load(filename) if File.exist?(filename)
    end
  end
end
