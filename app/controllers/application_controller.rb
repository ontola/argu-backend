# frozen_string_literal: true

require 'argu'
require 'argu/api'

class ApplicationController < ActionController::Base # rubocop:disable Metrics/ClassLength
  include Argu::Announcements
  include Argu::Controller::Authentication
  include Argu::Controller::ErrorHandling

  include ActiveResponse::Controller
  include ActiveResponseHelper
  include FrontendTransitionHelper
  include RailsLD::Helpers::OntolaActions
  include RedirectHelper
  include JsonApiHelper
  include NestedAttributesHelper
  include UsersHelper
  include NamesHelper
  include PublicActivity::StoreController
  include ApplicationHelper
  include AnalyticsHelper
  include ActorsHelper
  helper_method :current_profile, :show_trashed?, :preferred_forum, :user_context

  SAFE_METHODS = %w[GET HEAD OPTIONS CONNECT TRACE].freeze
  UNSAFE_METHODS = %w[POST PUT PATCH DELETE].freeze

  force_ssl unless: :internal_request?, host: Rails.application.config.frontend_url
  protect_from_forgery with: :exception, prepend: true, unless: :vnext_request?
  before_bugsnag_notify :add_user_info_to_bugsnag
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
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
    default_view: {member_sequence: :members},
    filters: [],
    sortings: [],
    operation: ACTION_FORM_INCLUDES
  ].freeze
  class_attribute :inc_shallow_collection
  self.inc_shallow_collection = [
    filters: [],
    sortings: [],
    operation: ACTION_FORM_INCLUDES
  ].freeze

  def self.controller_class
    @controller_class ||=
      name.sub(/Controller$/, '').classify.safe_constantize || controller_name.classify.safe_constantize
  end

  # The params, deserialized when format is json_api or LD and method is not safe
  # @example Resource params from json_api request
  #   params = {
  #     data: {type: 'motions', attributes: {body: 'body'}},
  #     relationships: {relation: {data: {type: 'motions', id: motion.id}}}
  #   }
  #   params # => {motion: {body: 'body', relation_type: 'motions', relation_id: 1}}
  # @example Resource params from LD request
  # @return [Hash] The params
  def params
    return @__params if instance_variable_defined?(:@__params)

    if UNSAFE_METHODS.include?(request.method)
      if parse_graph_params?
        p = HashWithIndifferentAccess.new
        p[model_name] = parse_filter(super[:filter], controller_class.try(:filter_options)) if super[:filter]
        return @__params = ActionController::Parameters.new(super.to_unsafe_h.deep_merge(p))
      end

      return @__params = json_api_params(super) if request.format.json_api? && super[:data].present?
    end

    @__params = super
  end

  def redirect_to(*args)
    args[0] = path_with_hostname(args[0]) if args[0].is_a?(String) && args[0].starts_with?('/')
    args[0] = args[0].dup.gsub("https://#{ENV['HOSTNAME']}", "https://app.#{ENV['HOSTNAME']}") if afe_request?
    super
  end

  private

  def add_user_info_to_bugsnag(notification)
    notification.user = {
      confirmed: current_user.confirmed?,
      id: current_user.id,
      ip: notification.user_id,
      responder_type: active_response_type,
      scopes: doorkeeper_scopes,
      shortname: current_user.url
    }
  end

  def after_sign_in_path_for(resource)
    if params[:host_url].present? && params[:host_url] == 'argu.freshdesk.com'
      freshdesk_redirect_url
    elsif params[:r] && argu_iri_or_relative?(params[:r])
      params[:r]
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

  def api_request?
    request.headers['Authorization'].present? &&
      cookies[Rails.configuration.cookie_name].blank? &&
      !request.format.html?
  end

  def authorize_forum(forum)
    return if forum.nil?
    return unless user_context.with_root_id(forum.root_id) do
      Pundit.policy(user_context, forum).show?
    end
    forum
  end

  def controller_class
    self.class.controller_class
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

  def internal_request?
    Argu::WhitelistConstraint.matches?(request)
  end

  def parse_graph_params?
    vnext_request? && !request.format.json_api?
  end

  # Uses Redis to fetch the {User}s last visited {Forum}, if not present uses
  # {Forum.first_public}.
  def preferred_forum(profile = nil)
    profile ||= current_profile
    @_preferred_forum ||=
      authorize_forum(current_forum) ||
      authorize_forum(profile.last_forum) ||
      authorize_forum(profile.preferred_forum) ||
      authorize_forum(Forum.first_public)
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
      Argu::Redis.setex("session:#{session_id}:last_forum", 1.day.seconds.to_i, current_forum.uuid)
    else
      Argu::Redis.set("profile:#{current_profile.id}:last_forum", current_forum.uuid)
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

  def vnext_request?
    afe_request? || api_request?
  end

  protected

  # @private
  # For Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer
      .permit(:sign_up, keys: [:email, :r, shortname_attributes: [:shortname]])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:r])
  end

  def is_flashing_format?
    true
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
    if current_user.guest?
      'guest'
    else
      'application'
    end
  end
end
