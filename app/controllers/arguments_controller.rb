# frozen_string_literal: true

class ArgumentsController < EdgeableController
  private

  def argument_type
    raise ActiveRecord::RecordNotFound unless params[:argument].try(:[], :pro)

    params[:argument][:pro].to_s == 'true' ? :pro : :con
  end

  def authenticated_resource!
    return super unless params[:action] == 'index'

    parent_resource!
  end

  def collection_from_parent_name
    "#{argument_type}_argument_collection"
  end

  def signals_failure
    [:"#{action_name}_pro_argument_failed", :"#{action_name}_con_argument_failed"]
  end

  def signals_success
    [:"#{action_name}_pro_argument_successful", :"#{action_name}_con_argument_successful"]
  end

  def redirect_location
    return super unless action_name == 'create' && authenticated_resource.persisted?

    authenticated_resource.parent.iri
  end
end
