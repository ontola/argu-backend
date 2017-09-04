# frozen_string_literal: true

class CurrentActor
  include ActiveModel::Model, ActiveModel::Serialization, Ldable, ProfilesHelper
  include Rails.application.routes.url_helpers

  attr_accessor :actor, :user
  delegate :display_name, to: :actor, allow_nil: true
  delegate :finished_intro, :context_id, :id, to: :user

  contextualize_as_type 'argu:CurrentActor'
  contextualize :display_name, as: 'schema:name'

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
    actor && dual_profile_url(actor)
  end
end
