# frozen_string_literal: true

class DiscussionsController < EdgeableController
  private

  def new
    return super unless controller_name == 'discussions'

    raise(ActiveRecord::RecordNotFound)
  end
end
