# frozen_string_literal: true

class RedisResourceWorker
  include Sidekiq::Worker

  def perform(old_user_class, old_user_id, new_user_class, new_user_id)
    old_user = get_user(old_user_class.constantize, old_user_id)
    new_user = get_user(new_user_class.constantize, new_user_id)

    redis_relation = RedisResource::Relation.where(publisher: old_user)
    return if redis_relation.empty?

    redis_relation.map { |r| r.resource.root_id }.uniq.each do |root_id|
      new_user.create_confirmation_reminder_notification(root_id)
    end
    redis_relation.persist(new_user)
  end

  private

  def get_user(klass, id)
    [User, LinkedRails::Auth::Registration].include?(klass) ? User.find(id) : GuestUser.new(id: id)
  end
end
