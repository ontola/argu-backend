# frozen_string_literal: true

class MediaObjectContentsController < ParentableController
  def show
    redirect_to url_for_version
  end

  private

  def authorize_action
    authorize parent_resource
  end

  def url_for_version
    case params[:version]
    when 'content'
      parent_resource.content
    when 'thumbnail'
      parent_resource.thumbnail
    when *MediaObjectUploader::VERSIONS.keys
      object.content.url(params[:version])
    else
      parent_resource.url
    end
  end
end
