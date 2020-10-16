# frozen_string_literal: true

namespace :cache do
  desc 'Refresh the cache'
  task refresh: %w[clear warm]

  desc 'Sends the clear signal to the cache, ensure the worker is running'
  task clear: :environment do
    Argu::Cache.invalidate_all
  end

  desc 'Warms the cache by requesting all resources in the system'
  task warm: :environment do
    Argu::Cache.warm
  end
end
