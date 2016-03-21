module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, ->(trashed = nil) do
      if self.column_names.include?('trashed_at')
        where((trashed === true ? nil : {trashed_at: nil}))
      else
        where((trashed === true ? nil : {is_trashed: false}))
      end
    end
    scope :anonymous, ->{where(creator_id: 0)}
  end

  def is_trashable?
    true
  end

  def is_trashed?
    if self.respond_to? :trashed_at
      self[:trashed_at]
    else
      self[:is_trashed]
    end
  end

  def trash
    self.class.transaction do
      if self.respond_to?(:trashed_at)
        update_column :trashed_at, DateTime.current
      else
        update_column :is_trashed, true
      end
      decrement_counter_cache if self.respond_to? :decrement_counter_cache
    end
  end

  def untrash
    return false unless self.is_trashed?

    self.class.transaction do
      if self.respond_to?(:trashed_at)
        update_column :trashed_at, nil
      else
        update_column :is_trashed, false
      end
      increment_counter_cache if self.respond_to? :increment_counter_cache
    end
    return true
  end

  module ClassMethods
    def anonymize(collection)
      collection.update_all(creator_id: 0, publisher_id: nil)
    end

    def is_trashable?
      true
    end
  end
end
