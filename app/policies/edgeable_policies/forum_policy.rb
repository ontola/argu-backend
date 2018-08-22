# frozen_string_literal: true

class ForumPolicy < EdgePolicy
  class Scope < Scope
    def resolve
      scope
        .property_join(:discoverable)
        .where('discoverable_filter.value = true OR edges.path ? '\
               "#{Edge.path_array(user.profile.granted_edges(root_id: grant_tree.tree_root_id))}")
    end
  end

  def permitted_attribute_names
    attributes = super
    attributes.concat %i[display_name bio bio_long profile_id locale public_grant page]
    attributes.concat %i[discoverable] if staff?
    attributes.concat %i[owner_type] if service?
    attributes
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i[general]
    tabs.concat %i[banners] if staff?
    tabs.concat %i[grants move delete] if vnext?
    tabs
  end

  def create?
    super || service?
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
end
