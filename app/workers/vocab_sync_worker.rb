# frozen_string_literal: true

class VocabSyncWorker
  include Sidekiq::Worker

  def perform
    VocabSyncer.sync_page
  end
end
