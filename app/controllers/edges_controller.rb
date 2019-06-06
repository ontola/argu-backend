# frozen_string_literal: true

class EdgesController < AuthorizedController
  def show
    redirect_to authenticated_resource.iri
  end

  private

  def resource_from_params
    resource = ActsAsTenant.without_tenant do
      r = super
      @tree_root = r.root
      r
    end
    ActsAsTenant.current_tenant = @tree_root
    resource
  end
end
