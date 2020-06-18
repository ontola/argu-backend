# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  InvalidateCacheWorker.perform_async(VERSION)
end
