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

  contextualize_as_type 'https://argu.co/ns/core#CurrentActor'
  contextualize_with_id { Rails.application.routes.url_helpers.c_a_url(protocol: :https) }
  contextualize :display_name, as: 'schema:name'
  contextualize :actor_type, as: 'https://argu.co/ns/core#actorType'

  def actor_type
    if actor.present?
      actor&.owner&.class&.name
    else
      'Guest'
    end
  end

  def context_type
    "argu:#{actor_type}Actor"
  end

  def shortname
    actor&.url
  end

  def url
    actor && dual_profile_url(actor, only_path: false)
  end
end
