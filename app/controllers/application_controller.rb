# frozen_string_literal: true

class ApplicationController < ActionController::API # rubocop:disable Metrics/ClassLength
  include ActionController::MimeResponds
  include ActiveResponse::Controller
  include LinkedRails::Controller
  include Argu::Controller::Authentication
  include Argu::Controller::ErrorHandling
  include ActiveResponseHelper
  include RedirectHelper
  include JsonAPIHelper
  include NestedAttributesHelper
  include UsersHelper
  include PublicActivity::StoreController
  include DeltaHelper
  include NestedResourceHelper

  SAFE_METHODS = %w[GET HEAD OPTIONS CONNECT TRACE].freeze
  UNSAFE_METHODS = %w[POST PUT PATCH DELETE].freeze

  before_action :verify_internal_ip, if: :service_token?
  before_bugsnag_notify :add_info_to_bugsnag

  prepend_before_action :current_actor
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_vary
  around_action :time_zone
  after_action :set_version_header
  after_action :include_resources

  def redirect_to(*args)
    args[0] = args[0].iri if args[0].respond_to?(:iri)
    args[0] = args[0].to_s if args[0].is_a?(RDF::URI)
    args[0] = path_with_hostname(args[0]) if args[0].is_a?(String) && args[0].starts_with?('/')
    super
  end

  private

  def add_info_to_bugsnag(notification)
    add_tenant_tab(notification)
    add_user_info(notification)
  end

  def add_tenant_tab(notification)
    notification.add_tab(
      :tenant,
      schema: Apartment::Tenant.current,
      server: ENV['SERVER_NAME'],
      tenant: ActsAsTenant.current_tenant&.iri_prefix,
      tenant_id: ActsAsTenant.current_tenant&.uuid
    )
  end

  def add_user_info(notification)
    notification.user = {
      confirmed: current_user.confirmed?,
      id: current_user.id,
      responder_type: active_response_type,
      scopes: doorkeeper_scopes,
      session_id: session_id,
      name: current_user.display_name
    }
  end

  def after_sign_in_path_for(resource) # rubocop:disable Metrics/AbcSize
    if params[:host_url].present? && params[:host_url] == 'argu.freshdesk.com'
      freshdesk_redirect_url
    elsif params[:redirect_url] && argu_iri_or_relative?(params[:redirect_url])
      params[:redirect_url]
    else
      super(resource || current_resource_owner)
    end
  end

  def api
    @api ||= Argu::API.new(
      service_token: ENV['SERVICE_TOKEN'],
      user_token: doorkeeper_token.token
    )
  end

  def controller_class
    self.class.controller_class
  end

  def include_resources
    response.headers['Include-Resources'] = current_resource.try(:include_resources)&.join(',') if request.head?
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def internal_request?
    LinkedRails::Constraints::Whitelist.matches?(request)
  end

  def serializer_params
    {
      scope: user_context
    }
  end

  # @private
  def set_locale
    I18n.locale = user_context.language
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

  def stored_location_for(_resource); end

  def time_zone(&block)
    time_zone = current_user.time_zone
    Time.use_zone(time_zone, &block)
  end

  def tree_root
    @tree_root ||= ActsAsTenant.current_tenant
  end

  def tree_root_id
    tree_root&.uuid
  end

  def url_for(obj)
    return super unless obj.is_a?(RDF::URI)

    obj.to_s
  end

  protected

  # @private
  # For Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email redirect_url accept_terms])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:redirect_url])
  end

  def is_flashing_format?
    false
  end

  # The name of the current model.
  # This is used primarily to wire data from the generic actions to their
  # resource-specific view variable names.
  def model_name
    controller_name.singularize.to_sym
  end

  def verify_internal_ip
    return true if internal_request?

    raise "IP #{request.remote_ip} is not allowed to make requests with a service token"
  end

  class << self
    def default_create_options(overwrite = {})
      super.merge(
        label: -> { I18n.t("#{self.class.actionable_class.name.tableize}.type_new", default: '').presence }
      ).merge(overwrite)
    end

    def default_destroy_options(overwrite = {})
      super.merge(
        target_url: lambda {
          resource.try(:singular_resource?) ? resource.singular_iri : resource.iri(destroy: true)
        }
      ).merge(overwrite)
    end
  end
end
