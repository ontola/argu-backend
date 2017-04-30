# frozen_string_literal: true
class VotePolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      if staff?
        scope
      else
        voter_ids = user.managed_profile_ids
        scope
          .joins(:creator)
          .where('profiles.are_votes_public = true OR profiles.id IN (?)', voter_ids)
          .joins(edge: {parent: :parent})
          .where(voteable_type: %w(Question Motion LinkedRecord), parents_edges_2: {trashed_at: nil})
          .joins('LEFT JOIN forums ON votes.forum_id = forums.id')
          .where('forums.id IS NULL OR forums.visibility = ? OR "forums"."id" IN (?)',
                 Forum.visibilities[:open],
                 user.profile.forum_ids)
      end
    end
  end

  module Roles
    def is_creator?
      creator if actor == record.creator
    end

    def is_group_member?
      group_grant if is_member? && user.profile.group_ids.include?(record.parent_model.group.id)
    end
  end
  include Roles

  def show?
    if record.creator.are_votes_public
      Pundit.policy(context, record.parent_model).show?
    else
      rule is_creator?, super
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat [:explanation, argument_ids: []]
    attributes
  end

  def create?
    return create_expired? if has_expired_ancestors?
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

  def has_expired_ancestors?
    record.parent_model.try(:closed?) || super
  end
end
