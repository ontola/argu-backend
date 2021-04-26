# frozen_string_literal: true

class TaggingsController < EdgeableController
  include LinkedRails::Enhancements::Indexable::Controller

  private

  def authorize_action
    return super unless action_name == 'index'

    authorize(parent_resource!, :show?)
  end

  class << self
    def controller_class
      Edge
    end
  end
end
