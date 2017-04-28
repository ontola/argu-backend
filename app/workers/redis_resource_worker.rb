# frozen_string_literal: true
class RedisResourceWorker
  include Sidekiq::Worker

  def perform(old_user_class, old_user_id, new_user_class, new_user_id)
    old_user = get_user(old_user_class.constantize, old_user_id)
    new_user = get_user(new_user_class.constantize, new_user_id)

    if new_user.confirmed?
      RedisResource::Relation.where(publisher: old_user).persist(new_user)
    else
      RedisResource::Relation.where(publisher: old_user).transfer(new_user)
    end
  end

  private

  def get_user(klass, id)
    klass == User ? User.find(id) : GuestUser.new(id: id)
  end
end
