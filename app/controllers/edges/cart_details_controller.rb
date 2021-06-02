# frozen_string_literal: true

class CartDetailsController < EdgeableController
  include LinkedRails::Enhancements::Destroyable::Controller

  private

  def create_success_message; end

  def destroy_success_message; end

  def allow_empty_params?
    true
  end
end
