# frozen_string_literal: true
namespace :delete do
  desc 'Delete tokens older than 60 days'
  task old_records: :environment do
    EXPIRY_PERIOD = 10.days.ago
    [Doorkeeper::AccessToken, Doorkeeper::AccessGrant].each do |model|
      model.delete_all(
        "created_at + (expires_in * interval '1 second') < ? OR revoked_at < ?",
        EXPIRY_PERIOD,
        EXPIRY_PERIOD
      )
    end
  end
end
