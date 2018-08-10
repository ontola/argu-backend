# frozen_string_literal: true

module Settingable
  module Policy
    def settings?
      update?
    end

    def tab?(tab)
      permitted_tabs.include?(tab.to_sym)
    end
  end
end
