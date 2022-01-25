# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  puts 'Caching properties'

  Edge.cache_properties
end
