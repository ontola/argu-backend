# frozen_string_literal: true
class ForumPolicy < EdgeTreePolicy
  class Scope < Scope
    def resolve
      scope.where('discoverable = true OR forums.id in (?)', user.profile.forum_ids)
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i(name bio bio_long profile_id) if update?
    attributes.concat %i(public_grant page_id) if change_owner?
    attributes.append(memberships_attributes: %i(role id profile_id forum_id))
    attributes.append(:max_shortname_count) if max_shortname_count?
    attributes.concat %i(discoverable) if staff?
    append_default_photo_params(attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general) if is_super_admin? || staff?
    tabs.concat %i(shortnames banners) if staff?
    tabs
  end

  def follow?
    rule is_member?, is_manager?, staff?
  end

  def list?
    raise(ActiveRecord::RecordNotFound) unless @record.discoverable? || show?
    true
  end

  def max_shortname_count?
    rule staff?
  end

  def settings?
    update?
  end

  private

  def create_roles
    [staff?]
  end

  alias show_roles default_show_roles
  alias show_unpublished_roles default_show_unpublished_roles

  def destroy_roles
    [is_super_admin?, super]
  end

  def update_roles
    [is_super_admin?, super]
  end
end
