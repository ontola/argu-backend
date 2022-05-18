# frozen_string_literal: true

class MigrateMediaObjectsWorker
  include Sidekiq::Worker

  def perform
    MediaObject.where('content_uid IS NOT NULL').find_each do |object|
      Apartment::Tenant.switch(Apartment::Tenant.current) do
        object.content.attach(io: URI.open(object.content_old.url), filename: object.content_uid)
      rescue StandardError => e
        object.update(migration_error: e.message)
      end
    end
  end
end
