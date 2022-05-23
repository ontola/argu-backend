# frozen_string_literal: true

class GrantedGroupsController < AuthorizedController
  private

  def verify_policy_scoped?
    false
  end

  class << self
    # GrantedGroups doesn't have a backing model which provides this method.
    def controller_class
      GrantedGroups
    end
  end
end
