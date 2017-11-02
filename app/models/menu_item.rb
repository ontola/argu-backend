# frozen_string_literal: true

class MenuItem
  include ActiveModel::Model
  include ActiveModel::Serialization
  include Ldable

  attr_accessor :label, :image, :parent, :tag, :menus, :href,
                :type, :description, :link_opts, :resource

  def initialize(attributes = {})
    super
    menus&.compact!
    menus&.each { |menu| menu.parent = self }
  end

  def as_json(_opts = {})
    {}
  end

  # Return options used by DropdownHelper#dropdown_options
  def dropdown_options(opts)
    (link_opts || {}).merge(fa: image).merge(opts)
  end

  def iri
    seperator = if parent.is_a?(MenuList)
                  '/'
                elsif parent.iri.to_s.include?('#')
                  '.'
                else
                  '#'
                end
    RDF::IRI.new "#{parent.iri}#{seperator}#{tag}"
  end
  alias id iri
end
