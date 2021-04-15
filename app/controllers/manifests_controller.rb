# frozen_string_literal: true

class ManifestsController < ApplicationController
  def show
    render json: Oj.dump(
      ManifestSerializer.new(tree_root.manifest).serializable_hash[:data][:attributes],
      mode: :compat
    )
  end

  private

  def current_resource; end

  def doorkeeper_render_error; end

  def valid_token?
    true
  end
end
