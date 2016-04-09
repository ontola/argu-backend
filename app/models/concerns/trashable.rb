module Trashable
  extend ActiveSupport::Concern

  included do
    scope :trashed, lambda do |trashed = nil|
      if column_names.include?('trashed_at')
        where((trashed === true ? nil : {trashed_at: nil}))
      else
        where((trashed === true ? nil : {is_trashed: false}))
      end
    end

    scope :trashed_only, lambda do
      if column_names.include?('trashed_at')
        where.not(trashed_at: nil)
      else
        where(is_trashed: true)
      end
    end

    scope :anonymous, -> { where(creator_id: 0) }
  end

  def is_trashable?
    true
  end

  def is_trashed?
    if respond_to?(:trashed_at)
      self[:trashed_at]
    else
      self[:is_trashed]
    end
  end

  def trash
    self.class.transaction do
      decrement_counter_cache if respond_to?(:decrement_counter_cache) && !is_trashed?
      if respond_to?(:trashed_at)
        update_column :trashed_at, DateTime.current
      else
        update_column :is_trashed, true
      end
      destroy_notifications
    end
  end

  def untrash
    self.class.transaction do
      increment_counter_cache if respond_to?(:increment_counter_cache) && is_trashed?
      if respond_to?(:trashed_at)
        update_column :trashed_at, nil
      else
        update_column :is_trashed, false
      end
    end
  end

  def destroy_notifications
    activities.each do |activity|
      activity.notifications.destroy_all
    end
  end

  module ClassMethods
    # Hands over ownership of a collection to the Community profile (0)
    def anonymize(collection)
      collection.update_all(creator_id: 0, publisher_id: nil)
    end

    def is_trashable?
      true
    end
  end
end
