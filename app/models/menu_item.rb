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

  def context_id
    seperator = if parent.is_a?(MenuList)
                  '/'
                elsif parent.context_id.include?('#')
                  '.'
                else
                  '#'
                end
    "#{parent.context_id}#{seperator}#{tag}"
  end
  alias id context_id

  def ld_type
    return RDF::IRI.new("https://argu.co/ns/core##{tag}Menu") if parent.is_a?(MenuList)
    menus.present? ? RDF::IRI.new(RDF::ARGU[:SubMenu]) : RDF::IRI.new(RDF::ARGU[:MenuItem])
  end
end
