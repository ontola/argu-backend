class PublicationsWorker
  include Sidekiq::Worker

  def perform(publishable_id, publishable_type)
    Publication.find_by(publishable_id: publishable_id, publishable_type: publishable_type).execute unless cancelled?
  end

  def cancelled?
    Sidekiq.redis {|c| c.exists("cancelled-#{jid}") }
  end

  def self.cancel!(jid)
    Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
  end
end
