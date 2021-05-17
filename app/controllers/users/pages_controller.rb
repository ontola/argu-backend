# frozen_string_literal: true

module Users
  class PagesController < AuthorizedController
    private

    def authorize_action
      return super unless action_name == 'index'

      authorize(parent_resource!, :update?)
    end
  end
end
