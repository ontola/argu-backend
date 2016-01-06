# Interface for the `flow` ability.
# Aka they have an activity stream coupled.
module Flowable
  extend ActiveSupport::Concern

  # Default flow implementation.
  # @note This should be overridden if the object isn't on the receiving end of the activity.
  # @return [ActiveRecord::CollectionProxy] The unfiltered activities belonging to this object.
  def flow
    activities = Activity.arel_table
    Activity.where(
      activities[:trackable_id].eq(id).and(
        activities[:trackable_type].eq(model_name.to_s))
        .or(activities[:recipient_id].eq(self).and(
          activities[:recipient_type].eq(model_name.to_s))))
  end
end
