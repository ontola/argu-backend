# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  include Argu::Controller::Authorization
  include RedisResourcesHelper
  include OauthHelper
  active_response :delete
  respond_to :json

  alias new_resource build_resource

  protected

  def after_sign_up_path_for(resource)
    if resource.url
      edit_user_url(resource.url)
    else
      setup_users_path
    end
  end

  def authorize_action
    return authorize(current_user, :show?) if action_name == 'delete'

    super
  end

  def sign_in(scope, resource)
    super(resource, scope)
  end

  def sign_up(resource_name, resource)
    super
    guest_user = GuestUser.new(id: session_id)

    mail_sent = send_confirmation_mail(
      resource,
      RedisResource::Relation.where(publisher: guest_user, parent: {owner_type: 'VoteEvent'})
    )
    resource.send_reset_password_token_email unless mail_sent
    schedule_redis_resource_worker(guest_user, resource, resource.redirect_url) if session_id.present?
  end

  private

  def build_resource(*args)
    super
    resource.shortname = nil if resource.shortname&.shortname.blank?
    resource.build_profile
    resource.language = I18n.locale
  end

  def current_resource
    @user || current_user
  end

  def delete_success
    respond_with_resource(
      include: action_form_includes,
      resource: current_user.action(:destroy, user_context),
      meta: [
        RDF::Statement.new(delete_iri('users'), NS::OWL.sameAs, delete_iri(current_user))
      ]
    )
  end

  def send_confirmation_mail(user, guest_votes) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    if guest_votes&.count&.positive?
      SendEmailWorker.perform_async(
        :confirm_votes,
        user.id,
        token_url: user_confirmation_url(user),
        motions: guest_votes.map do |guest_vote|
          m = guest_vote.resource.ancestor(:motion)
          {display_name: m.display_name, url: m.iri, option: guest_vote.resource.option} if m
        end.compact
      )
    elsif resource.password.present?
      SendEmailWorker.perform_async(:confirmation, user.id, token_url: user_confirmation_url(user))
    end
  end

  def user_confirmation_url(user)
    iri_from_template(:user_confirmation, confirmation_token: user.confirmation_token)
  end

  class << self
    def controller_class
      User
    end
  end
end
