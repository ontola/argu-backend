# frozen_string_literal: true

class ConversionsController < ServiceController
  before_action :verify_convertible_edge

  private

  def authorize_action
    authorize parent_resource!, :convert?
    authorize authenticated_resource, :new?
  end

  def create_success
    respond_with_redirect(
      location: authenticated_resource.edge.iri,
      reload: true
    )
  end

  def verify_convertible_edge
    raise "#{parent_resource!} is not convertible" unless parent_resource!.is_convertible?
  end
end
