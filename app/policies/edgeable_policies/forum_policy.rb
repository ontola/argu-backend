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
    attributes.concat %i[name bio bio_long profile_id locale public_grant page_id]
    attributes.append(:max_shortname_count) if max_shortname_count?
    attributes.concat %i[discoverable] if staff?
    append_default_photo_params(attributes)
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general]
    tabs.concat %i[shortnames banners] if staff?
    tabs
  end

  def invite?
    parent_policy(:page).update?
  end

  def list?
    raise(ActiveRecord::RecordNotFound) unless record.discoverable? || show?
    true
  end

  def max_shortname_count?
    staff?
  end

  def move?
    staff?
  end

  def settings?
    update?
  end
end
