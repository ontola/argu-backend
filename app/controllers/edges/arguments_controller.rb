# frozen_string_literal: true

class ArgumentsController < EdgeableController
  def redirect_location
    return super unless action_name == 'create' && authenticated_resource.persisted?

    authenticated_resource.parent.iri
  end
end
