# frozen_string_literal: true

class ForumPolicy < EdgeablePolicy
  class Scope < Scope
    def resolve
      scope
        .joins(:edge)
        .where("discoverable = true OR edges.path ? #{Edge.path_array(user.profile.granted_edges)}")
    end
  end

  def permitted_attributes
    attributes = super
    attributes.concat %i[name bio bio_long profile_id locale] if update?
    attributes.concat %i[public_grant page_id] if change_owner?
    attributes.append(memberships_attributes: %i[role id profile_id forum_id])
    attributes.append(:max_shortname_count) if max_shortname_count?
    attributes.concat %i[discoverable] if staff?
    append_default_photo_params(attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general] if is_super_admin? || staff?
    tabs.concat %i[shortnames banners] if staff?
    tabs
  end

  def destroy?
    rule is_super_admin?, super
  end

  def follow?
    rule is_member?, is_manager?, staff?
  end

  def invite?
    parent_policy(:page).update?
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

  def statistics?
    staff?
  end

  def update?
    rule is_super_admin?, super
  end
end
