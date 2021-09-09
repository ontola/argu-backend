# frozen_string_literal: true

class CartDetailsController < EdgeableController
  extend UriTemplateHelper
  include LinkedRails::Enhancements::Destroyable::Controller
  has_singular_create_action(
    image: font_awesome_iri('shopping-cart')
  )
  has_singular_destroy_action(
    type: lambda {
      [NS.ontola["Destroy::#{result_class}"], NS.ontola[:DestroyAction], NS.schema.Action]
    }
  )

  private

  def create_success_message; end

  def destroy_success_message; end

  def allow_empty_params?
    true
  end
end
