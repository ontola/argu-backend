# frozen_string_literal: true

module ActivityHelper
  # Generates an activity string for an activity in the sense of: 'Foo responded to your Bar'
  # @param [string] activity The Activity to generate the activity_string for
  # @param [User] user The User to generate the activity_string for
  # @param [Symbol] render Change the rendering behaviour of linked objects (defaults to display_name)
  def activity_string_for(activity, user, render: :display_name)
    Argu::ActivityString.new(activity, user, render: render).to_s
  end
end
