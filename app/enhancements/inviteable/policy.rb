# frozen_string_literal: true

module Inviteable
  module Policy
    extend ActiveSupport::Concern

    def invite?
      parent_policy(:page).update?
    end
  end
end
