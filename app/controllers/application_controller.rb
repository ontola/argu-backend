# frozen_string_literal: true

require 'argu'
require 'argu/api'

class ApplicationController < ActionController::Base
  include Argu::RuledIt
  include Argu::ErrorHandling
  include Argu::Authorization
  include Argu::Announcements

  include FrontendTransitionHelper
  include RedirectHelper
  include Common::Responses
  include JsonApiHelper
  include NestedAttributesHelper
  include UsersHelper
  include NamesHelper
  include PublicActivity::StoreController
  include ApplicationHelper
  include AnalyticsHelper
  include ActorsHelper
  helper_method :current_profile, :show_trashed?, :preferred_forum, :user_context

  protect_from_forgery with: :exception, prepend: true, unless: (lambda do
    headers['Authorization'].present? && cookies[Rails.configuration.cookie_name].blank?
  end)
  setup_authorization
  before_bugsnag_notify :add_user_info_to_bugsnag
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :authorize_current_actor
  before_action :set_vary
  after_action :set_profile_forum, if: :format_html?
  around_action :time_zone
  after_action :set_version_header
  if Rails.env.development? || Rails.env.staging?
    before_action do
      Rack::MiniProfiler.authorize_request if current_user.is_staff?
    end
  end

  layout :set_layout
  serialization_scope :user_context

  class_attribute :inc_nested_collection
  self.inc_nested_collection = [
    member_sequence: :members,
    operation: :target,
    view_sequence: [
      members:
        [
          member_sequence: :members,
          operation: :target,
          view_sequence: [members: [member_sequence: :members, operation: :target].freeze].freeze
        ].freeze
    ].freeze
  ].freeze

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
    if super['data']['type'].present? && super['data']['type'] != controller_name.camelcase(:lower)
      raise ActionController::UnpermittedParameters.new(%w[type])
    end
    raise ActionController::ParameterMissing.new(:attributes) if super['data']['attributes'].blank?
    ActionController::Parameters.new(
      super.to_unsafe_h.merge(
        super.require(:data).require(:type).singularize.underscore =>
          ActiveModelSerializers::Deserialization.jsonapi_parse!(super, deserialize_params_options)
      )
    )
  end

  private

  def add_user_info_to_bugsnag(notification)
    notification.user = {
      confirmed: current_user.confirmed?,
      id: current_user.id,
      ip: notification.user_id,
      scopes: doorkeeper_scopes,
      shortname: current_user.url
    }
  end

  def after_sign_in_path_for(resource)
    if params[:host_url].present? && params[:host_url] == 'argu.freshdesk.com'
      freshdesk_redirect_url
    else
      super(resource || current_resource_owner)
    end
  end

  def api
    @api ||= Argu::API.new(
      service_token: ENV['SERVICE_TOKEN'],
      user_token: request.cookie_jar.encrypted['argu_client_token'],
      cookie_jar: request.cookie_jar
    )
  end

  def authorize_current_actor
    authorize current_actor, :show?
  end

  def current_forum; end

  # @return [Profile] The {Profile} of the {User}
  def current_profile
    current_user.profile
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
    forum = Forum.find_via_shortname(geo.city.downcase) if geo.city.present?
    forum ||= Forum.find_via_shortname(geo.country.downcase) if geo.country.present?
    forum = Forum.find_via_shortname('eu') if forum.blank? && EU_COUNTRIES.include?(geo.country_code)
    forum
  end

  # Uses Redis to fetch the {User}s last visited {Forum}, if not present uses
  # {Forum.first_public}.
  def preferred_forum(profile = nil)
    profile ||= current_profile
    @_preferred_forum ||=
      [current_forum, profile.last_forum, profile.preferred_forum, Forum.first_public]
        .compact
        .uniq
        .find do |forum|
        user_context.with_root_id(forum.edge.parent_id) do
          policy(forum).show?
        end
      end
  end

  # @private
  def set_locale
    I18n.locale = current_user.language
  end

  def set_vary
    response.set_header('Vary', 'Accept')
    response.set_header('Vary', 'Content-Type')
    response.set_header('Vary', 'Authorization')
  end

  # @private
  def set_version_header
    response.headers['Argu-Version'] = ::VERSION
  end

  def set_profile_forum
    return if current_forum.blank?
    if current_user.guest?
      Argu::Redis.setex("session:#{session.id}:last_forum", 1.day.seconds.to_i, current_forum.id)
    else
      Argu::Redis.set("profile:#{current_profile.id}:last_forum", current_forum.id)
    end
  end

  def time_zone(&block)
    time_zone = current_user.time_zone
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

  protected

  # @private
  # For Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer
      .permit(:sign_up, keys: [:email, :r, shortname_attributes: [:shortname]])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:r])
  end

  # The name of the current model.
  # This is used primarily to wire data from the generic actions to their
  # resource-specific view variable names.
  def model_name
    controller_name.singularize.to_sym
  end

  # @private
  # Determines what layout the {User} should see.
  def set_layout
    if iframe?
      'iframe'
    elsif current_user.guest?
      'guest'
    else
      'application'
    end
  end

  # @private
  # For Devise
  def after_sending_reset_password_instructions_path_for(_resource_name)
    password_reset_confirm_path
  end
end
