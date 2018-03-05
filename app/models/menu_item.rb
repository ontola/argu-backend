# frozen_string_literal: true

class MenuItem
  include ActiveModel::Model
  include ActiveModel::Serialization
  include Ldable

  attr_accessor :label, :image, :parent, :tag, :menus, :href, :item_type,
                :type, :description, :link_opts, :resource

  def as_json(_opts = {})
    {}
  end

  # Return options used by DropdownHelper#dropdown_options
  def dropdown_options(opts)
    (link_opts || {}).merge(fa: image).merge(opts)
  end

  def iri(only_path: false)
    seperator =
      if parent.is_a?(MenuList)
        '/'
      elsif parent.iri.to_s.include?('#')
        '.'
      else
        '#'
      end
    RDF::URI("#{parent.iri(only_path: only_path)}#{seperator}#{tag}")
  end
  alias id iri

  def menu_sequence
    @menu_sequence ||= RDF::Sequence.new(menus&.call&.compact&.each { |menu| menu.parent = self })
  end
end
