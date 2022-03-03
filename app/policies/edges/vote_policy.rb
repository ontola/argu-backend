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

  permit_attributes %i[option option_id]

  def create?
    return super unless record.parent.is_a?(VoteEvent) && record.parent.starts_at > Time.current

    forbid_with_message(I18n.t('actions.votes.create.errors.not_started'))
  end

  def show?
    return if has_unpublished_ancestors? && !show_unpublished?

    (has_grant?(:show) && (record.publisher.show_feed? || is_creator?)) || staff? || service?
  end

  def trash?
    super && is_creator?
  end

  private

  def create_expired?
    forbid_with_status(NS.ontola[:ExpiredActionStatus], I18n.t('actions.votes.create.errors.finished'))
  end

  def is_creator?
    return current_session? if record.creator_id == User::GUEST_ID

    record.creator_id == profile.id || managed_profile_ids.include?(record.creator_id)
  end
end
