# frozen_string_literal: true
class VotePolicy < EdgeablePolicy
  class Scope < EdgeablePolicy::Scope
    def resolve
      if staff?
        scope
      else
        voter_ids = user.managed_profile_ids
        scope
          .joins(:creator, edge: {parent: :parent})
          .where("edges.path ? #{Edge.path_array(granted_edges_within_tree)}")
          .where('profiles.are_votes_public = true OR profiles.id IN (?)', voter_ids)
          .where(voteable_type: %w(Question Motion LinkedRecord),
                 parents_edges_2: {is_published: true, trashed_at: nil})
      end
    end
  end

  def show?
    if record.creator.are_votes_public
      super
    else
      is_creator? || has_grant_set?('staff') || service?
    end
  end

  private

  def is_creator?
    record.creator == actor || user.managed_profile_ids.include?(record.creator.id)
  end
end
