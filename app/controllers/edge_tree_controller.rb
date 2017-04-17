# frozen_string_literal: true

# Edge Tree Controllers provide a standard interface for accessing resources
# present in the edge tree.
#
# Since this controller includes `NestedResourceHelper`, subclassed models
# are assumed to have `Edgeable` included.
#
# @see EdgeTree::Setup The interface for adjusting per-component behaviour.
class EdgeTreeController < ServiceController
  include EdgeTree::Setup
  include NestedResourceHelper,
          EdgeTree::Create,
          EdgeTree::Edit,
          EdgeTree::Index,
          EdgeTree::New

  private

  # The name of the failure signal as emitted from `action_service`
  def signal_failure
    "#{action_name}_#{model_name}_failed".to_sym
  end

  # The name of the success signal as emitted from `action_service`
  def signal_success
    "#{action_name}_#{model_name}_successful".to_sym
  end

  # Method to determine where the action should redirect to after it succeeds.
  # @param [Class] resource The resource from the result of the action
  def success_redirect_model(resource)
    resource
  end
end
