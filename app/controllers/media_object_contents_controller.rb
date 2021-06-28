# frozen_string_literal: true

class MediaObjectContentsController < ParentableController
  before_action :redirect_to_image, if: :head_request?

  def active_response_custom_responses(format)
    format.html do
      redirect_to_image
    end
  end

  def show_success_rdf
    respond_with_resource(
      resource: nil,
      meta: [
        RDF::Statement.new(RDF::URI(request.original_url), NS.owl.sameAs, RDF::URI(url_for_version))
      ]
    )
  end

  private

  def authorize_action
    authorize parent_from_params!
  end

  def head_request?
    request.head?
  end

  def redirect_to_image
    redirect_to(url_for_version || raise(ActiveRecord::RecordNotFound))
  end

  def url_for_version # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    raise(ActiveRecord::RecordNotFound) unless parent_from_params.is_a?(MediaObject)

    case params[:version].to_sym
    when :content
      parent_from_params.content.url
    when :thumbnail
      parent_from_params.thumbnail
    when *MediaObjectUploader::IMAGE_VERSIONS.keys
      parent_from_params.content.url(params[:version])
    else
      parent_from_params.url
    end
  end
end
