# frozen_string_literal: true
class ForumPolicy < EdgeablePolicy
  class Scope < Scope
    def resolve
      scope
        .joins(:edge)
        .where("discoverable = true OR edges.path ? #{Edge.path_array(user.profile.granted_edges)}")
    end
  end

  def permitted_tabs
    tabs = []
    tabs.concat %i(general) if has_grant_set?(%w(administrator staff))
    tabs.concat %i(shortnames banners) if has_grant_set?('staff')
    tabs
  end

  def list?
    raise(ActiveRecord::RecordNotFound) unless record.discoverable? || show?
    true
  end

  def max_shortname_count?
    has_grant_set?('staff')
  end

  def settings?
    update?
  end

  def statistics?
    has_grant_set?('staff')
  end
end
