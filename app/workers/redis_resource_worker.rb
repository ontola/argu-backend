# frozen_string_literal: true

class RedisResourceWorker
  include Sidekiq::Worker

  def perform(old_user_class, old_user_id, new_user_class, new_user_id)
    old_user = get_user(old_user_class.constantize, old_user_id)
    new_user = get_user(new_user_class.constantize, new_user_id)

    redis_relation = RedisResource::Relation.where(publisher: old_user)
    return if redis_relation.empty?

    new_user.create_confirmation_reminder_notification
    new_user.confirmed? ? redis_relation.persist(new_user) : redis_relation.transfer(new_user)
  end

  private

  def get_user(klass, id)
    klass == User ? User.find(id) : GuestUser.new(id: id)
  end
end
