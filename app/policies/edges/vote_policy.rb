# frozen_string_literal: true

class VotePolicy < EdgePolicy
  class Scope < EdgePolicy::Scope
    def resolve
      return scope.none if user.nil?

      super
        .joins(:publisher, parent: :parent)
        .where('users.show_feed = true OR users.id = ?', user.guest? ? nil : user.id)
        .where(edges: {confirmed: true}, parents_edges_2: {is_published: true, trashed_at: nil})
    end
  end

  permit_attributes %i[option]

  def show? # rubocop:disable Metrics/CyclomaticComplexity
    return if has_unpublished_ancestors? && !show_unpublished?

    (has_grant?(:show) && (record.publisher.show_feed? || is_creator?)) || staff? || service?
  end

  def trash?
    super && is_creator?
  end

  private

  def is_creator?
    record.creator_id == profile.id || user.managed_profile_ids.include?(record.creator_id)
  end
end
