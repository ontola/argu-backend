# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  RebuildCacheWorker.perform_async(VERSION)
end
