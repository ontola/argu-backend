# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  puts 'Syncing grants'

  load(Rails.root.join('db/seeds/grant_sets.seeds.rb'))
end
