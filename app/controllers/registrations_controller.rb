# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  include Argu::Controller::Authorization
  include LinkedRails::Enhancements::Destroyable::Controller
  include RedisResourcesHelper
  include OauthHelper
  respond_to :json

  alias new_resource build_resource

  skip_before_action :authenticate_scope!, only: :destroy

  protected

  def after_sign_up_path_for(resource)
    if resource.url
      edit_user_url(resource.url)
    else
      setup_users_path
    end
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
    resource.accept_terms!(mail_sent) if accept_terms_param
    schedule_redis_resource_worker(guest_user, resource, resource.r) if session_id.present?
    setup_favorites(resource)
  end

  private

  def active_response_success_message
    return super unless action_name == 'destroy'
    I18n.t('type_destroy_success', type: 'Account')
  end

  def build_resource(*args)
    super
    resource.shortname = nil if resource.shortname&.shortname&.blank?
    resource.build_profile
    resource.language = I18n.locale
  end

  def current_resource
    @user || current_user
  end

  def delete_execute
    if current_user.guest?
      redirect_to root_path
      false
    else
      @user = current_user
    end
  end

  def destroy_execute # rubocop:disable Metrics/AbcSize
    @user = User.find current_user.id
    unless params[:user].try(:[], :confirmation_string) == I18n.t('users_cancel_string')
      @user.errors.add(:confirmation_string, I18n.t('errors.messages.should_match'))
    end
    return false if @user.errors.present? || !@user.destroy

    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    true
  end

  def destroy_success_location
    root_path
  end

  def send_confirmation_mail(user, guest_votes) # rubocop:disable Metrics/AbcSize
    if guest_votes&.count&.positive?
      SendEmailWorker.perform_async(
        :confirm_votes,
        user.id,
        token_url: user_confirmation_url(user),
        motions: guest_votes.map do |guest_vote|
          m = guest_vote.resource.ancestor(:motion)
          {display_name: m.display_name, url: m.iri, option: guest_vote.resource.for} if m
        end.compact
      )
    elsif resource.password.present?
      SendEmailWorker.perform_async(:confirmation, user.id, token_url: user_confirmation_url(user))
    end
  end

  def user_confirmation_url(user)
    iri_from_template(:user_confirmation, confirmation_token: user.confirmation_token)
  end
end
