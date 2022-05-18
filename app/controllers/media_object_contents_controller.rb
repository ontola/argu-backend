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

  def url_for_version # rubocop:disable Metrics/AbcSize
    raise(ActiveRecord::RecordNotFound) unless parent_from_params.is_a?(MediaObject)

    expires_in ActiveStorage.service_urls_expire_in

    case params[:version].to_sym
    when :thumbnail
      parent_from_params.private_url_for_version(:icon)
    when *MediaObjectUploader::IMAGE_VERSIONS.keys
      parent_from_params.private_url_for_version(params[:version])
    else
      parent_from_params.private_url_for_version(:content)
    end
  end
end
