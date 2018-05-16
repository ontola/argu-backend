# frozen_string_literal: true

class ForumPolicy < EdgeablePolicy
  class Scope < Scope
    def resolve
      scope
        .joins(:edge)
        .where("discoverable = true OR edges.path ? #{Edge.path_array(user.profile.granted_edges)}")
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[name bio bio_long profile_id locale public_grant page]
    attributes.concat %i[discoverable] if staff?
    append_default_photo_params(attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general]
    tabs.concat %i[banners] if staff?
    tabs
  end

  def invite?
    parent_policy(:page).update?
  end

  def list?
    raise(ActiveRecord::RecordNotFound) unless record.discoverable? || show?
    true
  end

  def move?
    staff?
  end

  def settings?
    update?
  end
end
