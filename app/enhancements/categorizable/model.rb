# frozen_string_literal: true

module Categorizable
  module Model
    extend ActiveSupport::Concern

    included do
      property :category_id, :linked_edge_id, NS::RIVM[:category]

      belongs_to :category, foreign_key_property: :category_id, class_name: 'Category', dependent: false

      with_collection :categories,
                      association: :category,
                      default_title: ->(_r) { I18n.t('categories.type') }
    end

    def category_id=(value)
      id = uuid?(value) ? value : Category.find_by!(root_id: root_id, id: value).uuid
      assign_property(:category_id, id)
      super(id)
    end

    def parent_collections(user_context)
      super + [category&.measure_type_collection(user_context: user_context)]
    end
  end
end
