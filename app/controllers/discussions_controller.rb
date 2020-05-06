# frozen_string_literal: true

class DiscussionsController < EdgeableController
  private

  def check_if_registered?
    return super unless controller_name == 'discussions'

    super && !%w[new index].include?(action_name)
  end

  def new
    return super unless controller_name == 'discussions'

    raise(ActiveRecord::RecordNotFound)
  end
end
