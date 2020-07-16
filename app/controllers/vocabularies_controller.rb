# frozen_string_literal: true

class VocabulariesController < LinkedRails::VocabulariesController
  after_action :set_cache_control_public, only: :show, if: :valid_response?

  private

  def authorize_action; end
end
