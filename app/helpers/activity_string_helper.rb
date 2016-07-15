# frozen_string_literal: true
module ActivityStringHelper
  include AlternativeNamesHelper, ProfilesHelper

  # Generates an activity string for an activity in the sense of: 'Foo responded to your Bar'
  # Params:
  # +activity+:: The Activity to generate the HRS for
  # +embedded_link+:: Set to true to embed an anchor link (defaults to false)
  def activity_string_for(activity, embedded_link = false)
    Argu::ActivityString.new(activity, embedded_link).to_s
  end
end
