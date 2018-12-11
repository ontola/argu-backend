# frozen_string_literal: true

class CreateComment < PublishedCreateService
  def initialize(parent, attributes: {}, options: {})
    if attributes.delete(:is_opinion)&.to_s == 'true'
      attributes[:vote_id] = current_vote(options[:publisher], parent)&.uuid
    end
    super
  end

  private

  def current_vote(user, parent)
    user
      .profile
      .vote_cache
      .by_parent(parent.default_vote_event)
  end
end
