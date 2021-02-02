# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  Apartment::Tenant.each do
    puts "Syncing grants for #{Apartment::Tenant.current}"

    load(Rails.root.join('db/seeds/grant_sets.seeds.rb'))
  end
end
