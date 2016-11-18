# frozen_string_literal: true
class ProjectPolicy < EdgeTreePolicy
  class Scope < EdgeTreePolicy::Scope
    attr_reader :context, :scope

    def initialize(context, scope)
      @context = context
      @profile = user.profile if user
      @scope = scope
    end

    delegate :user, to: :context
  end
  include ApplicationHelper

  def permitted_attributes
    attributes = super
    attributes.concat %i(id title content start_date end_date achieved_end_date email cover_photo remove_cover_photo
                         cover_photo_attribution unpublish) if create?
    attributes.concat %i(pinned) if is_manager? || staff?
    phase = record.is_a?(Project) && Edge.new(owner: Phase.new, parent: record.edge).owner
    attributes.append(phases_attributes: Pundit.policy(context, phase).permitted_attributes(true)) if phase && create?
    stepup = record.is_a?(Project) && Stepup.new(record: record, forum: record.forum)
    if stepup && (record.try(:new_record?) || is_manager_up?)
      attributes.append(stepups_attributes: Pundit.policy(context, stepup).permitted_attributes(true))
    end
    append_default_photo_params(attributes)
    attributes
  end

  def create?
    assert_publish_type
    return unless active_for_user?(:projects, user)
    rule is_moderator?, is_manager?, is_owner?, super
  end

  def destroy?
    user && (record.creator_id == user.profile.id && 15.minutes.ago < record.created_at) ||
      is_manager? ||
      is_owner? ||
      super
  end

  def list?
    if record.is_published? && !record.is_trashed?
      rule has_access_token?, is_member?, is_manager?, is_owner?, super
    else
      rule is_moderator?, is_manager?, is_owner?, super
    end
  end

  def show?
    return show_unpublished? if has_unpublished_ancestors?
    rule has_access_token?, is_member?, is_moderator?, is_manager?, is_owner?, super
  end

  def trash?
    rule is_moderator?, is_creator?, is_manager?, is_owner?, super
  end

  def untrash?
    rule is_moderator?, is_creator?, is_manager?, is_owner?, super
  end

  def update?
    rule is_moderator?, is_manager?, is_owner?, super
  end
end
