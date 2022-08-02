# frozen_string_literal: true

class ManifestsController < LinkedRails::ManifestsController
  skip_before_action :authorize_action
  skip_after_action :verify_authorized

  private

  def current_resource
    tree_root.manifest
  end

  def doorkeeper_render_error; end

  def valid_token?
    true
  end
end
