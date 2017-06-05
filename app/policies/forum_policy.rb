# frozen_string_literal: true
class ForumPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope.where('discoverable = true OR forums.id in (?)', user.profile.forum_ids)
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name bio bio_long tags featured_tags profile_id) if update?
    attributes.concat %i(public_grant page_id) if change_owner?
    attributes.append(memberships_attributes: %i(role id profile_id forum_id))
    attributes.append(:max_shortname_count) if max_shortname_count?
    attributes.concat %i(discoverable) if staff?
    append_default_photo_params(attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general advanced shortnames banners) if is_manager? || staff?
    tabs
  end

  # #####Actions######
  def create?
    super
  end

  def follow?
    rule is_member?, is_manager?, staff?
  end

  def groups?
    rule is_manager?, staff?
  end

  def list?
    raise(ActiveRecord::RecordNotFound) unless @record.discoverable? || show?
    true
  end

  def list_members?
    rule is_super_admin?, staff?
  end

  def managers?
    rule is_super_admin?, staff?
  end

  def max_shortname_count?
    rule staff?
  end

  def settings?
    update?
  end

  def statistics?
    super
  end

  def update?
    rule is_manager?, super
  end

  def add_motion?
    rule is_member?, staff?
  end

  def add_question?
    rule is_member?, staff?
  end
end
