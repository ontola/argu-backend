# frozen_string_literal: true
module Listable
  extend ActiveSupport::Concern

  included do
    has_many :list_items, -> { order(:order) }, as: :listable, dependent: :destroy

    # Add an item to the end of the list
    # @param [String] relationship The relationship to the list of the new item
    # @param [String] iri The iri of the resource
    # @param [String] resource_type The type of the resource
    # @return [ListItem] The newly created ListItem
    def add_item(relationship, iri, resource_type)
      list_items.create!(
        relationship: relationship,
        iri: iri,
        resource_type: resource_type,
        order: send(relationship).count
      )
    end

    # Replace all items in the list with a new array of values
    # @param [String] relationship The relationship to the list of the new items
    # @param [Array<Hash{iri => String, resource_type => String}>] array The new items
    # @return [ActiveRecord::Associations::CollectionProxy<ListItems>] The new items
    def replace_items(relationship, *array)
      array = array.first if array.first.is_a?(Array)
      raise 'Please provide an array of values' unless array.is_a?(Array)
      list_items.destroy_all
      array.each { |value| add_item(relationship, value.fetch(:iri), value.fetch(:resource_type)) }
      list_items
    end
  end

  module ClassMethods
    # Adds an association for list_items with a specific relationship
    # Also defines add_{single_name} and replace_{plural_name} methods
    # @example has_many_list_items :voteables
    #   has_many :voteables, -> { where(relationship: 'voteables').order(:order) }, class_name: 'ListItem'
    #   add_voteable(iri, resource_type)
    #   replace_voteables(array)
    def has_many_list_items(name)
      has_many name, -> { where(relationship: name).order(:order) }, class_name: 'ListItem', as: :listable

      define_method "add_#{name.to_s.singularize}" do |iri, resource_type|
        add_item(name, iri, resource_type)
      end

      define_method "replace_#{name}" do |array|
        replace_items(name, array)
      end
    end
  end
end
