# frozen_string_literal: true

class InfoController < ApplicationController
  # TODO: Create InfoPolicy and validate documents accordingly.
  def show
    setting = Setting.get(params[:id])
    raise ActiveRecord::RecordNotFound if setting.blank?

    active_response_block do
      respond_with_resource(
        include: :sections,
        resource: InfoDocument.new(iri: RDF::URI(request.original_url), json: JSON.parse(setting))
      )
    end
  rescue JSON::ParserError
    raise ActiveRecord::RecordNotFound
  end
end
