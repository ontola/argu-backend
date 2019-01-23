# frozen_string_literal: true

class MenuItem
  include ActiveModel::Model
  include ActiveModel::Serialization
  include RailsLD::Model

  attr_accessor :action, :label, :parent, :tag, :menus, :href, :item_type,
                :type, :description, :link_opts, :resource
  attr_writer :image, :iri_base, :iri_tag

  def as_json(_opts = {})
    {}
  end

  # Return options used by DropdownHelper#dropdown_options
  def dropdown_options(opts)
    (link_opts || {}).merge(fa: image).merge(opts)
  end

  def image
    @image = @image.call if @image.respond_to?(:call)
    @image
  end

  def iri_path(fragment: nil)
    fragment = "##{fragment}" if fragment
    seperator =
      if parent.is_a?(MenuList)
        '/'
      elsif parent.iri.to_s.include?('#')
        '.'
      else
        fragment = nil
        '#'
      end
    "#{iri_base}#{seperator}#{iri_tag}#{fragment}"
  end
  alias id iri

  def menu_sequence
    return if menus.blank?
    @menu_sequence ||=
      RDF::LazySequence.new(
        -> { menus&.call&.compact&.each { |menu| menu.parent = self } },
        id: menu_sequence_iri
      )
  end

  def menu_sequence_iri
    RDF::DynamicURI(path_with_hostname("#{iri_path}/menus"))
  end

  private

  def iri_base
    @iri_base&.call || parent.iri_path
  end

  def iri_tag
    @iri_tag || tag
  end

  class << self
    def preview_includes
      [:image, action: :target]
    end
  end
end
