module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, ->(trashed = nil) { where((trashed === true ? nil : {is_trashed: false})) }
  end

  def is_trashed?
    read_attribute :is_trashed
  end

  def trash
    self.class.transaction do
      update_column :is_trashed, true
      if (self.respond_to? :votes)
        self.votes.update_all is_trashed: true
      end
      refresh_counter_cache if self.respond_to? :refresh_counter_cache
    end
  end

  module ClassMethods
  end
end
