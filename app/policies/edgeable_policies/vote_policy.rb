# frozen_string_literal: true

class VotePolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope
    def resolve
      voter_ids = user.managed_profile_ids
      scope
        .joins(:creator, edge: {parent: :parent})
        .where("edges.path ? #{Edge.path_array(granted_edges_within_tree)}")
        .where('profiles.are_votes_public = true OR profiles.id IN (?)', voter_ids)
        .where(parents_edges_2: {is_published: true, trashed_at: nil})
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat [:explanation, argument_ids: []]
    attributes
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    (record.creator.are_votes_public && has_grant?(:show)) || is_creator? || staff? || service?
  end

  private

  def is_creator?
    record.creator == actor || user.managed_profile_ids.include?(record.creator.id)
  end
end
