# frozen_string_literal: true
class GuestProfile < Profile
  def last_forum
    forum_id = Argu::Redis.get("session:#{profileable.id}:last_forum")
    Forum.find_by(id: forum_id) if forum_id.present?
  end

  def preferred_forum
    Forum.first_public
  end
end
