# frozen_string_literal: true

class CollectionSorting < RailsLD::CollectionSorting
  include Iriable

  def iri(_opts = {})
    self
  end

  def sort_value
    return super unless children_count_sorting?
    Edge.order_child_count_sql(attribute_name.to_s.gsub('_count', ''), direction: direction)
  end

  private

  def children_count_sorting?
    attribute_name.to_s.ends_with?('_count') && attribute_name.to_sym != :follows_count
  end
end
