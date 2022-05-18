# frozen_string_literal: true

class PurgeUnattachedBlobsWorker < NotificationsSchedulerWorker
  include Sidekiq::Worker

  def perform
    ActiveStorage::Blob.unattached.where('active_storage_blobs.created_at <= ?', 2.days.ago).find_each do |blob|
      Apartment::Tenant.switch(Apartment::Tenant.current) do
        blob.purge
      end
    end
  end
end
