# frozen_string_literal: true
require 'argu/ruled_it'
require 'argu/not_authorized_error'
require 'argu/not_a_user_error'

class ApplicationController < ActionController::Base
  include Argu::RuledIt, ActorsHelper, AnalyticsHelper, ApplicationHelper, OauthHelper,
          PublicActivity::StoreController, AccessTokenHelper, NamesHelper, UsersHelper,
          NestedAttributesHelper, JsonApiHelper
  helper_method :current_profile, :show_trashed?, :collect_announcements

  protect_from_forgery with: :exception, prepend: true
  prepend_before_action :check_for_access_token
  skip_before_action :verify_authenticity_token, unless: :verify_authenticity_token?
  prepend_before_action :write_client_access_token
  before_action :set_layout
  before_action :doorkeeper_authorize!
  before_action :check_finished_intro, if: :format_html?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index
  after_action :set_profile_forum
  around_action :set_time_zone
  after_action :set_version_header
  # after_action :set_notification_header
  if Rails.env.development? || Rails.env.staging?
    before_action do
      Rack::MiniProfiler.authorize_request if current_user && current_user.profile.has_role?(:staff)
    end
  end

  rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
  rescue_from Argu::NotAuthorizedError, with: :handle_not_authorized_error
  rescue_from Argu::NotAUserError, with: :handle_not_a_user_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_bad_request
  rescue_from ActionController::UnpermittedParameters, with: :handle_bad_request
  rescue_from ActionController::BadRequest, with: :handle_bad_request
  rescue_from ActiveRecord::StaleObjectError, with: :rescue_stale
  rescue_from Redis::ConnectionError, with: :handle_redis_connection_error
  rescue_from ActionController::RoutingError, with: :route_not_found
  def route_not_found
    @_pundit_policy_authorized = true
    respond_to do |format|
      format.json_api { render status: 404, json: {error: 'not found'} }
    end
  end

  serialization_scope :doorkeeper_scopes

  def verify_authenticity_token?
    doorkeeper_token.nil? || doorkeeper_guest_token? || !doorkeeper_oauth_header?
  end

  def after_sign_in_path_for(resource)
    if params[:host_url].present? && params[:host_url] == 'argu.freshdesk.com'
      freshdesk_redirect_url
    else
      super(resource || current_resource_owner)
    end
  end

  def collect_announcements
    return @announcements if @announcements.present?

    announcements = stubborn_hgetall('announcements') || {}
    if announcements.present? && announcements.is_a?(String)
      announcements = JSON.parse(announcements)
    end
    @announcements = policy_scope(Announcement)
                     .reject { |a| announcements[a.identifier] == 'hidden' }
  end

  # @return [Profile, nil] The {Profile} the {User} is using to do actions
  def current_profile
    @current_profile ||= get_current_actor if current_user.present?
  end

  # The params, deserialized when format is json_api and method is not GET
  # @return [Hash] The params
  # @example Resource params from json_api request
  #   params = {
  #     data: {type: 'motions', attributes: {body: 'body'}},
  #     relationships: {relation: {data: {type: 'motions', id: motion.id}}}
  #   }
  #   params # => {motion: {body: 'body', relation_type: 'motions', relation_id: 1}}
  def params
    return super unless request.format.json_api? && request.method != 'GET' && super[:data].present?
    if super['data']['type'].present? && super['data']['type'] != controller_name
      raise ActionController::UnpermittedParameters.new(%w(type))
    end
    raise ActionController::ParameterMissing.new(:attributes) unless super['data']['attributes'].present?
    ActionController::Parameters.new(
      super.to_unsafe_h.merge(
        super.require(:data).require(:type).singularize =>
          ActiveModelSerializers::Deserialization.jsonapi_parse!(super, deserialize_params_options)
      )
    )
  end

  def deserialize_params_options
    {}
  end

  def format_html?
    request.format.html?
  end

  def forum_by_geocode
    geo = session[:geo_location]
    return if geo.nil?
    forum = Forum.find_via_shortname_nil(geo.city.downcase) if geo.city.present?
    forum ||= Forum.find_via_shortname_nil(geo.country.downcase) if geo.country.present?
    forum = Forum.find_via_shortname_nil('eu') if forum.blank? && EU_COUNTRIES.include?(geo.country_code)
    forum
  end

  # Uses Redis to fetch the {User}s last visited {Forum}, if not present uses {Forum.first_public}
  def preferred_forum(profile = nil)
    profile ||= current_profile
    if profile.present?
      @_preferred_forum = profile.preferred_forum
      if @_preferred_forum && policy(@_preferred_forum).show?
        @_preferred_forum
      else
        mem_forum =
          profile
          .granted_records('Forum')
          .map do |e|
            @_preferred_forum = e.owner
            e.owner if policy(e.owner).show?
          end
          .compact
          .presence
        mem_forum || Forum.first_public
      end
    else
      forum_id = Argu::Redis.get("session:#{session.id}:last_forum")
      @_preferred_forum = Forum.find_by(id: forum_id) if forum_id.present?
      @_preferred_forum = nil if @_preferred_forum.present? && !policy(@_preferred_forum).show?
      @_preferred_forum || Forum.first_public
    end
  end

  # @private
  def pundit_user
    UserContext.new(
      current_user,
      current_profile,
      session[:a_tokens]
    )
  end

  def rescue_stale
    respond_to do |format|
      format.html do
        correct_stale_record_version
        stale_record_recovery_action
      end
      format.xml  { head :conflict }
      format.json { head :conflict }
    end
  end

  # @private
  def set_locale
    I18n.locale =
      current_user.try(:language) ||
      cookies['locale'] ||
      http_accept_language.compatible_language_from(I18n.available_locales)
  end

  # @private
  def set_notification_header
    if current_user.present?
      response.headers[:lastNotification] = policy_scope(Notification)
                                            .order(created_at: :desc)
                                            .limit(1)
                                            .pluck(:created_at)[0] || '-1'
    else
      response.headers[:lastNotification] = '-1'
    end
  end

  # @private
  def set_version_header
    response.headers['Argu-Version'] = ::VERSION
  end

  def set_profile_forum
    if instance_variable_defined?(:@forum) && @forum.is_a?(Forum) && current_profile.present?
      Argu::Redis.set("profile:#{current_profile.id}:last_forum", @forum.id)
    elsif instance_variable_defined?(:@forum) && @forum.is_a?(Forum)
      Argu::Redis.setex("session:#{session.id}:last_forum", 1.day.seconds.to_i, @forum.id)
    end
  end

  def set_time_zone(&block)
    time_zone = current_user&.time_zone || 'Amsterdam'
    Time.use_zone(time_zone, &block)
  end

  # Has the {User} enabled the `trashed` `param` and is he authorized?
  def show_trashed?
    if params[:trashed].present? && policy(resource_by_id).update?
      params[:trashed] == 'true'
    else
      false
    end
  end

  def skip_verify_policy_scoped(sure = false)
    @_pundit_policy_scoped = true if sure
  end

  protected

  # @private
  # For Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :r, :access_tokens, shortname_attributes: [:shortname]])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:r])
  end

  # @private
  # Before_action which redirects the {User} if he didn't finish the intro.
  def check_finished_intro
    return unless current_user
    if current_user.url.blank?
      redirect_to setup_users_path if request.original_url != setup_users_url
    elsif !current_user.finished_intro? && !request.original_url.in?(intro_urls)
      redirect_to setup_profiles_url
    end
  end

  def handle_record_not_unique(exception)
    respond_to do |format|
      format.json do
        error_hash = {
          type: :error,
          error_id: 'NOT_UNIQUE',
          message: exception.message
        }
        render status: 304,
               json: error_hash.merge(notifications: [error_hash])
      end
      format.json_api do
        error_hash = {
          message: exception.message,
          code: 'NOT_UNIQUE'
        }
        render json_api_error(304, error_hash)
      end
      format.html do
        flash[:warning] = t(:twice_warning)
        redirect_back(fallback_location: root_path)
      end
    end
  end

  def handle_not_authorized_error(exception)
    @_not_authorized_caught = true
    Rails.logger.error exception
    error_hash = {
      type: :error,
      error_id: 'NOT_AUTHORIZED',
      message: exception.message
    }
    respond_to do |format|
      format.js do
        render status: 403,
               json: error_hash.merge(notifications: [error_hash])
      end
      format.json do
        render status: 403,
               json: error_hash.merge(notifications: [error_hash])
      end
      format.json_api do
        error_hash = {
          message: exception.message,
          code: 'NOT_AUTHORIZED'
        }
        render json_api_error(403, error_hash)
      end
      format.html do
        user = User.new(r: request.original_url, shortname: Shortname.new) if @resource.class != User
        flash[:alert] = exception.message
        render 'status/403', status: 403, locals: {resource: user, message: exception.message}
      end
    end
  end

  def handle_not_a_user_error(exception)
    @_not_a_user_caught = true
    respond_to do |format|
      format.js do
        @resource = User.new(r: exception.r, shortname: Shortname.new) if @resource.class != User
        render 'devise/sessions/new',
               layout: false,
               locals: {
                 resource: @resource,
                 resource_name: :user,
                 devise_mapping: Devise.mappings[:user],
                 r: exception.r
               }
      end
      format.json do
        render status: 401,
               json: {
                 notifications: [{
                   type: :error,
                   message: exception.message
                 }]
               }
      end
      format.json_api { render json_api_error(401, exception.message) }
      format.html { redirect_to new_user_session_path(r: exception.r), alert: exception.message }
    end
  end

  def handle_record_not_found(exception)
    @quote = (Setting.get(:quotes) || '').split(';').sample
    @additional_error_info = exception.to_s
    respond_to do |format|
      format.html do
        user = User.new(r: request.original_url, shortname: Shortname.new) if @resource.class != User
        render 'status/404', status: 404, locals: {resource: user}
      end
      format.js { head 404 }
      format.json do
        render status: 404,
               json: {
                 title: t('status.s_404.header'),
                 message: t('status.s_404.body'),
                 quote: @quote
               }
      end
      format.json_api { render json_api_error(404) }
    end
  end

  def handle_bad_request(exception)
    @additional_error_info = exception.to_s
    respond_to do |format|
      format.html { render 'status/400', status: 400 }
      format.json do
        render status: 400,
               json: {
                 title: t('status.s_400.header'),
                 message: t('status.s_400.body'),
                 quote: @quote
               }
      end
      format.json_api do
        error_hash = {
          message: exception.to_s,
          code: 'BAD_REQUEST'
        }
        render json_api_error(400, error_hash)
      end
      format.js { head 400 }
    end
  end

  def handle_redis_connection_error(exception)
    Redis.rescue_redis_connection_error(exception)
  end

  # @private
  def intro_urls
    [profile_url(current_user), setup_profiles_url]
  end

  # @private
  # Determines what layout the {User} should see.
  def set_layout
    if current_user.present? && current_user.finished_intro? && current_user.url.present?
      self.class.layout 'application'
    elsif current_user.present? && current_user.url.blank?
      self.class.layout 'closed'
    else
      self.class.layout 'guest'
    end
  end

  def stale_record_recovery_action
    flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
    render :edit, status: :conflict
  end

  # @private
  # For Devise
  def after_sending_reset_password_instructions_path_for(_resource_name)
    password_reset_confirm_path
  end
end
