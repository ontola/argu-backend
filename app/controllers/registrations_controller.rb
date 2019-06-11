# frozen_string_literal: true

require 'spam_checker'

class RegistrationsController < Devise::RegistrationsController
  include Argu::Controller::Authorization
  include LinkedRails::Enhancements::Destroyable::Controller
  include RedisResourcesHelper
  include OauthHelper
  respond_to :json

  alias new_resource build_resource

  skip_before_action :authenticate_scope!, only: :destroy
  skip_before_action :verify_authenticity_token, if: :api_request?
  before_action :handle_spammer, if: :is_spam?, only: :create

  def create
    super
    session[:omniauth] = nil unless @user.new_record? || afe_request?
  end

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
      session.presence && RedisResource::Relation
                            .where(publisher: guest_user, parent: {owner_type: 'VoteEvent'})
    )
    resource.accept_terms!(mail_sent) if accept_terms_param
    schedule_redis_resource_worker(guest_user, resource, resource.r) if session_id.present?
    setup_favorites(resource)
  end

  private

  def active_response_success_message
    return super unless action_name == 'destroy'
    t('type_destroy_success', type: 'Account')
  end

  def build_resource(*args) # rubocop:disable Metrics/AbcSize
    super
    resource.shortname = nil if resource.shortname&.shortname&.blank?
    resource.build_profile
    resource.language = I18n.locale
    return unless session[:omniauth]
    @user.apply_omniauth(session[:omniauth])
    @user.valid?
  end

  def current_resource
    @user || current_user
  end

  def delete_execute
    if current_user.guest?
      flash[:error] = 'Not signed in'
      redirect_to root_path
      false
    else
      @user = current_user
    end
  end

  def destroy_execute # rubocop:disable Metrics/AbcSize
    @user = User.find current_user.id
    unless params[:user].try(:[], :confirmation_string) == t('users_cancel_string')
      @user.errors.add(:confirmation_string, t('errors.messages.should_match'))
    end
    return false if @user.errors.present? || !@user.destroy

    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    true
  end

  def destroy_success_location
    root_path
  end

  def handle_spammer
    render 'application/spam', content: @content_checked_for_spam
  end

  def send_confirmation_mail(user, guest_votes) # rubocop:disable Metrics/AbcSize
    if guest_votes&.count&.positive?
      SendEmailWorker.perform_async(
        :confirm_votes,
        user.id,
        confirmationToken: user.confirmation_token,
        motions: guest_votes.map do |guest_vote|
          m = guest_vote.resource.ancestor(:motion)
          {display_name: m.display_name, url: m.iri, option: guest_vote.resource.for} if m
        end.compact
      )
    elsif resource.password.present?
      SendEmailWorker.perform_async(:confirmation, user.id, confirmationToken: user.confirmation_token)
    end
  end

  def is_spam? # rubocop:disable Metrics/AbcSize
    r = sign_up_params[:r] || params[:r]
    body = Rack::Utils.parse_nested_query(r&.split('?')&.second).with_indifferent_access
    @content_checked_for_spam = body[:comment].try(:[], :body)
    return false if @content_checked_for_spam.blank?
    SpamChecker.new(content: @content_checked_for_spam, email: sign_up_params[:email]).spam?
  end
end
