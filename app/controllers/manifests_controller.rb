# frozen_string_literal: true

class ManifestsController < ApplicationController
  def show
    render json: tree_root.manifest, adapter: :attributes, key_transform: :underscore
  end
end
