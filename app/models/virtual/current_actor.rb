# frozen_string_literal: true

class CurrentActor < VirtualResource
  include LinkedRails::Helpers::OntolaActionsHelper

  attr_accessor :profile, :user

  delegate :display_name, to: :profile, allow_nil: true
  delegate :id, :default_profile_photo, :default_profile_photo_id, :has_analytics?, to: :user

  def actor_type # rubocop:disable Metrics/MethodLength
    if profile.present?
      owner = profile.profileable
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

  def mount_action
    return if user.guest? || user.finished_intro

    ontola_dialog_action(LinkedRails.iri(path: expand_uri_template(:setup_iri)))
  end

  def primary_email
    user&.primary_email_record&.email
  end

  def rdf_type
    NS::ONTOLA[actor_type]
  end

  def shortname
    profile&.url
  end

  def user_id
    user&.id
  end
end
