# frozen_string_literal: true

class CollectionSorting < LinkedRails::Collection::Sorting
  include LinkedRails::Model

  def iri(_opts = {})
    self
  end
  alias canonical_iri iri

  def sort_value
    return super unless children_count_sorting?
    Edge.order_child_count_sql(attribute_name.to_s.gsub('_count', ''), direction: direction)
  end

  private

  def children_count_sorting?
    attribute_name.to_s.ends_with?('_count') && attribute_name.to_sym != :follows_count
  end
end
