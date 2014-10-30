module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, ->(trashed) { where(is_trashed: trashed.present?) }
  end

  def trash
    update_column :is_trashed, true
  end


  module ClassMethods

  end
end
