# frozen_string_literal: true

module Actions
  class ItemsController < LinkedRails::Actions::ItemsController
    skip_before_action :authorize_action, only: %i[index]
  end
end
