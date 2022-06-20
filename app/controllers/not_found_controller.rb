# frozen_string_literal: true

class NotFoundController < LinkedRails::NotFoundController
  skip_after_action :verify_authorized
end
