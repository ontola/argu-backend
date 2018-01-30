# frozen_string_literal: true

module Listable
  extend ActiveSupport::Concern

  included do
    has_many :list_items, -> { order(:order) }, as: :listable, dependent: :destroy

    # Add an item to the end of the list
    # @param [String] relationship The relationship to the list of the new item
    # @param [String] item_iri The iri of the resource
    # @param [String] item_type The type of the resource
    # @return [ListItem] The newly created ListItem
    def add_item(relationship, item_iri, item_type)
      list_items.create!(
        relationship: relationship,
        item_iri: item_iri,
        item_type: item_type,
        order: send(relationship).count
      )
    end

    # Replace all items in the list with a new array of values
    # @param [String] relationship The relationship to the list of the new items
    # @param [Array<Hash{item_iri => String, item_type => String}>] array The new items
    # @return [ActiveRecord::Associations::CollectionProxy<ListItems>] The new items
    def replace_items(relationship, *array)
      array = array.first if array.first.is_a?(Array)
      raise 'Please provide an array of values' unless array.is_a?(Array)
      send(relationship).destroy_all
      array.each { |value| add_item(relationship, value.fetch(:item_iri), value.fetch(:item_type)) }
      list_items
    end
  end

  module ClassMethods
    # Adds an association for list_items with a specific relationship
    # Also defines add_{single_name} and replace_{plural_name} methods
    # @example has_many_list_items :voteables
    #   has_many :voteables, -> { where(relationship: 'voteables').order(:order) }, class_name: 'ListItem'
    #   add_voteable(item_iri, item_type)
    #   replace_voteables(array)
    def has_many_list_items(name)
      has_many name, -> { where(relationship: name).order(:order) }, class_name: 'ListItem', as: :listable
      with_collection name, association_class: ListItem

      define_method "add_#{name.to_s.singularize}" do |item_iri, item_type|
        add_item(name, item_iri, item_type)
      end

      define_method "replace_#{name}" do |array|
        replace_items(name, array)
      end
    end
  end
end
