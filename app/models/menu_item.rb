# frozen_string_literal: true

class MenuItem
  include ActiveModel::Model
  include ActiveModel::Serialization
  include Ldable

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

  def iri(only_path: false, fragment: nil)
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
    RDF::DynamicURI("#{iri_base(only_path)}#{seperator}#{iri_tag}#{fragment}")
  end
  alias id iri

  def menu_sequence
    @menu_sequence ||= RDF::Sequence.new(menus&.call&.compact&.each { |menu| menu.parent = self })
  end

  private

  def iri_base(only_path)
    @iri_base&.call(only_path) || parent.iri(only_path: only_path)
  end

  def iri_tag
    @iri_tag || tag
  end
end
