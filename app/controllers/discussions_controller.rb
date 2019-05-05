# frozen_string_literal: true

class DiscussionsController < EdgeableController
  # @todo remove after release of new FE
  active_response :new

  # @todo remove after release of new FE
  def default_form_options(_action)
    return super unless controller_name == 'discussions'
    {action: :form}
  end

  private

  # @todo remove after release of new FE
  def authorize_action
    authorize parent_resource, :list?
    return super unless action_name == 'new' && controller_name == 'discussions'

    true
  end

  def check_if_registered?
    return super unless controller_name == 'discussions'

    super && !%w[new index].include?(action_name)
  end
end
