# frozen_string_literal: true

class PublicationsWorker
  include Sidekiq::Worker

  def perform(publishable_id)
    return if cancelled?

    pub = Publication.find_by(publishable_id: publishable_id)
    pub.subscribe ActivityListener.new(publisher: pub.publisher, creator: pub.creator)
    pub.commit
  end

  def cancelled?
    Argu::Redis.exists("cancelled-#{jid}")
  end

  def self.cancelled?(jid)
    Argu::Redis.exists("cancelled-#{jid}")
  end

  def self.cancel!(jid)
    Argu::Redis.setex("cancelled-#{jid}", 86_400, 1)
  end
end
