module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, ->(trashed = nil) { where((trashed === true ? nil : {is_trashed: false})) }
  end

  def is_trashed?
    read_attribute :is_trashed
  end

  def trash
    update_column :is_trashed, true
  end

  module ClassMethods

  end
end
