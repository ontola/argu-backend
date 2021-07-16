# frozen_string_literal: true

class RedisResourceWorker
  include Sidekiq::Worker

  def perform(old_identifier, new_identifier)
    old_user = User.from_identifier(old_identifier)
    new_user = User.from_identifier(new_identifier)

    redis_relation = RedisResource::Relation.where(publisher: old_user)
    return if redis_relation.empty?

    redis_relation.map { |r| r.resource.root_id }.uniq.each do |root_id|
      new_user.create_confirmation_reminder_notification(root_id)
    end
    redis_relation.persist(new_user)
  end
end
