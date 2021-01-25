# frozen_string_literal: true

class PublicationsWorker
  include Sidekiq::Worker
  include DeltaHelper

  def perform(publishable_id)
    return if cancelled?

    @publication = Publication.find_by(publishable_id: publishable_id)
    @publication.subscribe ActivityListener.new(publisher: @publication.publisher, creator: @publication.creator)
    @publication.commit

    broadcast_publication
  end

  private

  def broadcast_publication
    RootChannel.broadcast_to(resource.root, publish_delta) if resource.root.live_updates?
    UserChannel.broadcast_to(@publication.publisher, publish_delta)
  end

  def cancelled?
    Argu::Redis.exists?("cancelled-#{jid}")
  end

  def publish_delta
    hex_delta(resource_added_delta(resource))
  end

  def resource
    @publication.publishable
  end

  class << self
    def cancelled?(jid)
      Argu::Redis.exists?("cancelled-#{jid}")
    end

    def cancel!(jid)
      Argu::Redis.setex("cancelled-#{jid}", 86_400, 1)
    end
  end
end
