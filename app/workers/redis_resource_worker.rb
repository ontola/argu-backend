# frozen_string_literal: true

class RedisResourceWorker
  include Sidekiq::Worker

  def perform(old_user_class, old_user_id, new_user_id)
    old_user = get_user(old_user_class, old_user_id)
    new_user = User.find(new_user_id)

    redis_relation = RedisResource::Relation.where(publisher: old_user)
    return if redis_relation.empty?

    redis_relation.map { |r| r.resource.root_id }.uniq.each do |root_id|
      new_user.create_confirmation_reminder_notification(root_id)
    end
    redis_relation.persist(new_user)
  end

  private

  def get_user(klass, id)
    return User.guest(id) if klass == 'GuestUser'

    User.find(id)
  end
end
