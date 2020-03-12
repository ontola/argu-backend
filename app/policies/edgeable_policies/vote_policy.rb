# frozen_string_literal: true

class VotePolicy < EdgePolicy
  class Scope < EdgePolicy::Scope
    def resolve
      super
        .joins(:publisher, parent: :parent)
        .where('users.show_feed = true OR users.id = ?', user.guest? ? nil : user.id)
        .where(edges: {confirmed: true}, parents_edges_2: {is_published: true, trashed_at: nil})
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.append(:option)
  end

  def show? # rubocop:disable Metrics/CyclomaticComplexity
    return if has_unpublished_ancestors? && !show_unpublished?

    (record.publisher.show_feed? && has_grant?(:show)) || is_creator? || staff? || service?
  end

  private

  def is_creator?
    record.creator_id == actor.id || user.managed_profile_ids.include?(record.creator_id)
  end
end
