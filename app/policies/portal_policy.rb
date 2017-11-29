# frozen_string_literal: true

class PortalPolicy < RestrictivePolicy
  def permitted_tabs
    tabs = []
    tabs.concat(%i[general documents setting announcements]) if staff?
    tabs
  end

  def home?
    staff?
  end
end
