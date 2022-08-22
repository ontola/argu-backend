# frozen_string_literal: true

class Placement < ApplicationRecord
  include Cacheable
  include Parentable

  belongs_to :edge, primary_key: :uuid

  acts_as_tenant :root, class_name: 'Edge', primary_key: :uuid
  parentable :edge

  validates :lat, :lon, :zoom_level, presence: true

  attr_writer :coordinates

  collection_options(
    page_size: 100
  )

  def coordinates
    [lat, lon]
  end

  def display_name
    coordinates.join(', ')
  end

  class << self
    def attributes_for_new(opts)
      super.merge(edge: opts[:parent])
    end

    def collection_from_parent_name(_parent, _params)
      :children_placement_collection
    end
  end
end
