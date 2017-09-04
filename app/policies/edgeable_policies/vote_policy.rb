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
          .where(voteable_type: %w[Question Motion LinkedRecord],
                 parents_edges_2: {is_published: true, trashed_at: nil})
      end
    end
  end

  module Roles
    def is_group_member?
      group_grant if is_member? && user.profile.group_ids.include?(record.parent_model.group_id)
    end
  end
  include Roles

  def show?
    if record.creator.are_votes_public
      Pundit.policy(context, record.parent_model).show?
    else
      rule is_creator?, staff?, service?
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat [:explanation, argument_ids: []]
    attributes
  end

  def create?
    return create_expired? if has_expired_ancestors?
    return create_trashed? if has_trashed_ancestors?
    if record.parent_model.is_a?(VoteEvent)
      rule is_group_member?
    else
      rule is_member?, is_manager?, is_super_admin?, super
    end
  end

  def update?
    rule is_creator?, super
  end

  def destroy?
    rule is_creator?, super
  end
end
