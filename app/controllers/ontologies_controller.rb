# frozen_string_literal: true

class OntologiesController < LinkedRails::OntologiesController
  skip_before_action :authorize_action
  skip_after_action :verify_authorized
end
