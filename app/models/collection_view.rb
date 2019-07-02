# frozen_string_literal: true

class CollectionView < LinkedRails::Collection::View
  include IRITemplateHelper

  def members
    m = super
    if association_class <= Edge && association_class != Page
      m.each { |member| user_context.grant_tree.cache_node(member) }
    end
    m
  end
end
