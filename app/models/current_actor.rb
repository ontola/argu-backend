# frozen_string_literal: true

class CurrentActor
  include ProfilesHelper
  include Ldable
  include ActiveModel::Serialization
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  attr_accessor :actor, :user
  delegate :display_name, to: :actor, allow_nil: true
  delegate :id, to: :user

  def actor_type
    if actor.present?
      actor&.owner&.class&.name
    else
      'Guest'
    end
  end

  def shortname
    actor&.url
  end

  def url
    actor && dual_profile_url(actor, only_path: false)
  end
end
