# The shared logic on trashing items
# Can be used in conjunction with `CounterChainable` since it checks for and calls `update_counter_chain` or otherwise `update_counters`
module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, ->(trashed = nil) { where((trashed === true ? nil : {is_trashed: false})) }

    def trash
      self.class.transaction do
        update_column :is_trashed, true
        if self.respond_to? :update_counter_chain
          update_counter_chain
        elsif self.respond_to? :update_counters
          update_counters
        end
      end
    end
  end

  def is_trashed?
    read_attribute :is_trashed
  end
end
