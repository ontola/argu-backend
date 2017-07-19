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
          .where('forums.id IS NULL OR "forums"."id" IN (?)', user.profile.forum_ids)
      end
    end
  end

  module Roles
    def is_group_member?
      group_grant if is_member? && user.profile.group_ids.include?(record.parent_model.group_id)
    end
  end
  include Roles

  def permitted_attributes
    attributes = super
    attributes.concat [:explanation, argument_ids: []]
    attributes
  end

  def show?
    if record.creator.are_votes_public
      Pundit.policy(context, record.parent_model).show?
    else
      super
    end
  end

  private

  def create_roles
    if record.parent_model.is_a?(VoteEvent)
      [is_group_member?]
    else
      [is_member?, is_manager?, is_super_admin?, super]
    end
  end

  def show_roles
    [is_creator?, super]
  end

  def update_roles
    [is_creator?]
  end

  def destroy_roles
    [is_creator?]
  end
end
