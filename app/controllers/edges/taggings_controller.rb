# frozen_string_literal: true

class TaggingsController < EdgeableController
  controller_class Edge

  private

  def authorize_action
    return super unless action_name == 'index'

    authorize(parent_resource!, :show?)
  end
end
