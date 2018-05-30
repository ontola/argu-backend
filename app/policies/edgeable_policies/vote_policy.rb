# frozen_string_literal: true

class VotePolicy < EdgePolicy
  class Scope < EdgePolicy::Scope
    def resolve
      voter_ids = user.managed_profile_ids
      scope
        .joins(:creator, parent: :parent)
        .where("edges.path ? #{path_array}")
        .where('profiles.are_votes_public = true OR profiles.id IN (?)', voter_ids)
        .where(edges: {confirmed: true}, parents_edges_2: {is_published: true, trashed_at: nil})
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.append(:option)
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    (record.creator.are_votes_public && has_grant?(:show)) || is_creator? || staff? || service?
  end

  private

  def is_creator?
    record.creator_id == actor.id || user.managed_profile_ids.include?(record.creator_id)
  end
end
