# frozen_string_literal: true

namespace :delete do
  desc 'Delete tokens older than 60 days'
  task old_records: :environment do
    expiry_period = 10.days.ago
    [Doorkeeper::AccessToken, Doorkeeper::AccessGrant].each do |model|
      model
        .where("created_at + (expires_in * INTERVAL '1 second') < ? OR revoked_at < ?",
               expiry_period,
               expiry_period)
        .delete_all
    end
  end
end
