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
    rule is_member?, is_manager?, is_super_admin?, staff?
  end

  def update?
    rule is_creator?, super
  end

  def destroy?
    rule is_creator?, super
  end
end
