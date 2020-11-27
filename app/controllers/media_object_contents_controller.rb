# frozen_string_literal: true

class MediaObjectContentsController < ParentableController
  def active_response_custom_responses(format)
    format.html do
      redirect_to url_for_version || raise(ActiveRecord::RecordNotFound)
    end
  end

  def show_success_rdf
    respond_with_resource(
      resource: nil,
      meta: [
        RDF::Statement.new(RDF::URI(request.original_url), NS::OWL.sameAs, RDF::URI(url_for_version))
      ]
    )
  end

  private

  def authorize_action
    authorize parent_resource!
  end

  def url_for_version # rubocop:disable Metrics/AbcSize
    case params[:version].to_sym
    when :content
      parent_resource.content.url
    when :thumbnail
      parent_resource.thumbnail
    when *MediaObjectUploader::IMAGE_VERSIONS.keys
      parent_resource.content.url(params[:version])
    else
      parent_resource.url
    end
  end
end
