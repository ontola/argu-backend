# frozen_string_literal: true

Rake::Task['db:migrate'].enhance do
  VocabSyncer.sync_all
end
