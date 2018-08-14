# frozen_string_literal: true

class GuestProfile < Profile
  include NoPersistence

  def last_forum
    forum_id = Argu::Redis.get("session:#{profileable.id}:last_forum")
    Forum.find_by(uuid: forum_id) if uuid?(forum_id)
  end

  def preferred_forum
    Forum.first_public
  end

  private

  def iri_template_name
    :profiles_iri
  end
end
