# frozen_string_literal: true

class LinkedRecordsController < EdgeableController
  def requested_resource
    @requested_resource ||= LinkedRecord.find_or_initialize_by_iri(
      params[:iri],
      request.env['HTTP_AUTHORIZATION'],
      request.env['HTTP_ACCEPT_LANGUAGE']
    )
  end
end
