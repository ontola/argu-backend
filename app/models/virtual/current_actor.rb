# frozen_string_literal: true

class CurrentActor < VirtualResource
  include LinkedRails::Helpers::OntolaActionsHelper

  attr_accessor :profile, :user

  delegate :display_name, to: :profile, allow_nil: true
  delegate :id, :default_profile_photo, :default_profile_photo_id, :has_analytics?, to: :user

  def actor_type # rubocop:disable Metrics/MethodLength
    if profile.present?
      owner = profile.profileable
      if owner.guest?
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

  def anonymous_iri?
    false
  end

  def mount_action
    return if user.guest? || user.finished_intro

    ontola_dialog_action(LinkedRails.iri(path: expand_uri_template(:setup_iri)))
  end

  def primary_email
    user&.primary_email_record&.email
  end

  def rdf_type
    NS.ontola[actor_type]
  end

  def unread_notification_count
    Pundit.policy_scope(UserContext.new(user: user), Notification).where(read_at: nil).count
  end

  def user_id
    user&.id
  end
end
