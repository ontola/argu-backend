module Trashable
  extend ActiveSupport::Concern

  included do
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

    # Scope to filter trashed items
    # @param [boolean] trashed Whether trashed records should be included
    # @return [ActiveRecord::Relation]
    def trashed(trashed = nil)
      scope_type = column_names.include?('trashed_at') ? {trashed_at: nil} : {is_trashed: false}
      scope = trashed === true ? nil : scope_type
      where(scope)
    end

    # Scope to select only trashed items.
    # @return [ActiveRecord::Relation]
    def trashed_only
      if column_names.include?('trashed_at')
        where.not(trashed_at: nil)
      else
        where(is_trashed: true)
      end
    end
  end
end
