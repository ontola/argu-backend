# frozen_string_literal: true

class CartDetailActionList < EdgeActionList
  has_singular_create_action(
    image: font_awesome_iri('shopping-cart')
  )
  has_singular_destroy_action(
    type: lambda {
      [NS::ONTOLA["Destroy::#{result_class}"], NS::ONTOLA[:DestroyAction], NS::SCHEMA.Action]
    }
  )
end
