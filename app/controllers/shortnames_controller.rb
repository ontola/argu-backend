# frozen_string_literal: true

class ShortnamesController < ParentableController
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique

  private

  def redirect_location
    settings_iri(authenticated_resource.root, tab: 'shortnames')
  end
end
