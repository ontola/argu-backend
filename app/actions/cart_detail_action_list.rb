# frozen_string_literal: true

class CartDetailActionList < EdgeActionList
  extend LinkedRails::Enhancements::Destroyable::Action::ClassMethods

  has_action(
    :create,
    create_options.merge(
      image: font_awesome_iri('shopping-cart')
    )
  )
  has_action(
    :destroy,
    destroy_options.merge(
      collection: true,
      image: font_awesome_iri('close'),
      policy_resource: -> { resource.parent.cart_detail_for(user_context.user) },
      predicate: NS::ONTOLA[:removeFromCart]
    )
  )
end
