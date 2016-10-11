# frozen_string_literal: true
require 'argu/activity_string'

module ActivityHelper
  include NamesHelper, ProfilesHelper

  # Generates an activity string for an activity in the sense of: 'Foo responded to your Bar'
  # @param [string] activity The Activity to generate the activity_string for
  # @param [User] user The User to generate the activity_string for
  # @param [bool] embedded_link Set to true to embed an anchor link (defaults to false)
  def activity_string_for(activity, user, embedded_link = false)
    Argu::ActivityString.new(activity, user, embedded_link).to_s
  end

  # Decide whether to include the body when rendering this Activity on the feed
  def render_body_on_feed?(activity)
    case activity.object
    when 'decision'
      %w(update create).exclude?(activity.action)
    when 'vote'
      return false
    when 'project', 'blog_post'
      activity.action == 'publish'
    else
      activity.action == 'create'
    end
  end
end
