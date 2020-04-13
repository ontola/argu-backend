# frozen_string_literal: true

class ManifestsController < ApplicationController
  def show
    render json: tree_root.manifest, adapter: :attributes, key_transform: :underscore
  end

  private

  def doorkeeper_render_error; end

  def valid_token?
    true
  end
end
