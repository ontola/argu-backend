# frozen_string_literal: true

class CurrentActor
  include ProfilesHelper
  include LinkedRails::Model
  include ActiveModel::Serialization
  include ActiveModel::Model
  include ApplicationModel
  include Rails.application.routes.url_helpers

  attr_accessor :actor, :user

  delegate :display_name, to: :actor, allow_nil: true
  delegate :id, to: :user

  def actor_type # rubocop:disable Metrics/MethodLength
    if actor.present?
      owner = actor.profileable
      if owner.is_a?(GuestUser)
        'GuestUser'
      elsif owner.confirmed?
        'ConfirmedUser'
      else
        'UnconfirmedUser'
      end
    else
      'GuestUser'
    end
  end

  def shortname
    actor&.url
  end

  def url
    actor && dual_profile_url(actor, only_path: false)
  end
end
