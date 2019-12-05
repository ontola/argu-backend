# frozen_string_literal: true

class MenuItem < LinkedRails::Menus::Item
  attr_writer :image, :link_opts, :description

  %i[image link_opts description].each do |method|
    callable_variable(method, instance: :parent)
  end

  # Return options used by DropdownHelper#dropdown_options
  def dropdown_options(opts)
    (link_opts || {}).merge(fa: image).merge(opts)
  end

  def menu_sequence_iri
    RDF::DynamicURI(super)
  end

  def menu_sequence
    return LinkedRails::Sequence.new([], id: menu_sequence_iri) if parent.user_context.tree_root.nil?

    super
  end
end
