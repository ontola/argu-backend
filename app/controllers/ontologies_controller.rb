# frozen_string_literal: true

class OntologiesController < LinkedRails::VocabulariesController
  after_action :set_cache_control_public, only: :show, if: :valid_response?
  skip_before_action :authorize_action
  skip_after_action :verify_authorized
end
