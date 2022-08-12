# frozen_string_literal: true

class PollPolicy < EdgePolicy
  permit_attributes %i[display_name description]
  permit_attributes %i[pinned], grant_sets: %i[moderator administrator staff]

  def permitted_tabs
    tabs = %i[participate submission]
    if update?
      tabs.push(:form)
      tabs.push(:submissions)
    end
    tabs
  end
end
