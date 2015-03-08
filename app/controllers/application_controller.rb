class ApplicationController < ActionController::Base
  include Pundit, ActorsHelper, ApplicationHelper, ConvertibleHelper, PublicActivity::StoreController, AccessTokenHelper
  helper_method :current_profile, :current_context, :current_scope, :show_trashed?
  protect_from_forgery secret: "Nl4EV8Fm3LdKayxNtIBwrzMdH9BD18KcQwSczxh1EdDbtyf045rFuVces8AdPtobC9pp044KsDkilWfvXoDADZWi6Gnwk1vf3GghCIdKXEh7yYg41Tu1vWaPdyzH7solN33liZppGlJlNTlJjFKjCoGjZP3iJhscsYnPVwY15XqWqmpPqjNiluaSpCmOBpbzWLPexWwBSOvTcd6itoUdWUSQJEVL3l0rwyJ76fznlNu6DUurFb8bOL2ItPiSit7g"
  skip_before_filter  :verify_authenticity_token
  prepend_before_action :check_for_access_token
  before_action :check_finished_intro
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_layout
  after_action :verify_authorized, :except => :index, :unless => :devise_controller?
  after_action :verify_policy_scoped, :only => :index

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:vote_same_twice_warning)
    redirect_to :back
  }

  rescue_from Pundit::NotAuthorizedError do |exception|
    Rails.logger.error exception
    respond_to do |format|
      format.js { render 403, json: { notifications: [{type: :error, message: t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}") }] } }
      format.json { render 403, json: { notifications: [{type: :error, message: t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}") }] } }
      format.html {
        request.env['HTTP_REFERER'] = request.env['HTTP_REFERER'] == request.original_url || request.env['HTTP_REFERER'].blank? ? root_path : request.env['HTTP_REFERER']
        redirect_to :back, :alert => exception.message
      }
    end
  end

  rescue_from Argu::NotLoggedInError do |exception|
    respond_to do |format|
      format.js { render 403, json: { notifications: [{type: :error, message: t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}") }] } }
      format.html {
        r = request.env['HTTP_REFERER'] = request.env['HTTP_REFERER'] == request.original_url || request.env['HTTP_REFERER'].blank? ? root_path : request.env['HTTP_REFERER']
        @resource ||= User.new r: r.to_s
        render 'devise/sessions/new', locals: { resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user], r: r, preview: exception.preview }
      }
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    @quote = Setting.get(:quotes).split(';').sample
    respond_to do |format|
      format.html { render 'status/404', status: 404 }
      format.json { render json: { title: t('status.s_404.header'), message: t('status.s_404.body'), quote: @quote}, status: 404 }
    end
  end

  def create_activity_with_cleanup(model, params)
    destroy_recent_similar_activities model, params
    create_activity model, params
  end

  def create_activity(model, params)
    a = model.create_activity params
    Argu::NotificationWorker.perform_async(a.id)
  end

  def current_scope
    current_context.context_scope(current_profile) || current_context
  end

  # Returns the current context, if a param is given, it will serve as the start of the current context
  def current_context(model=nil)
    @current_context ||= Context.parse_from_uri(request.url, model)
  end

  # @return #Profile
  def current_profile
    if current_user.present?
      @current_profile ||= get_current_actor
    else
      nil
    end
  end

  def preferred_forum
    policy(current_profile.preferred_forum).show? ? current_profile.preferred_forum : current_profile.memberships.first.try(:forum) || Forum.first_public
  end

  def pundit_user
    UserContext.new(current_user, current_profile, session)
  end

  def render_register_modal(base_url=nil, *r_options)
    if !r_options || r_options.first != false   # Only skip if r_options is false
      r = URI.parse(base_url || request.fullpath)
      r.query= r_options.reject { |a| a.to_a.last.blank? }.map { |a| a.to_a.join('=') }.join('&')
    else
      r = nil
    end
    @resource ||= User.new r: r.to_s
    respond_to do |format|
      format.js { render 'devise/sessions/new', layout: false, locals: { resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user], r: CGI::escape(r.to_s) } }
      format.html { render template: 'devise/sessions/new', locals: { resource: @resource, resource_name: :user, devise_mapping: Devise.mappings[:user], r: CGI::escape(r.to_s) } }
    end
  end

  def set_locale
    unless current_user.nil?
      I18n.locale = current_user.settings.locale || I18n.default_locale
    end
  end

  def destroy_recent_similar_activities(model, params)
    Activity.delete Activity.where("created_at >= :date", :date => 6.hours.ago).where(trackable_id: model.id, owner_id: params[:owner].id, key: "#{model.class.name.downcase}.create").pluck(:id)
  end

  def show_trashed?
    params[:trashed] == 'true' if policy(current_scope.model).update?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:username, :email, :r, :access_tokens]
    devise_parameter_sanitizer.for(:sign_in) << [:r]
    devise_parameter_sanitizer.for(:accept_invitation).concat [:username]
  end

  def check_finished_intro
    if current_user && !current_user.finished_intro? && !request.original_url.in?(intro_urls)
      if current_user.profile.name.present?
        redirect_to selector_forums_url
      else
        redirect_to edit_profile_url(current_user.username)
      end
    end
  end

  def intro_urls
    [selector_forums_url, profile_url(current_user.username), edit_profile_url(current_user.username), memberships_forums_url, ]
  end

  def set_layout
    if request.headers['X-PJAX']
      self.class.layout false
    elsif current_user.present? && current_user.finished_intro?
      self.class.layout 'application'
    elsif has_valid_token?
      self.class.layout 'guest'
    else
      self.class.layout 'closed'
    end
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    password_reset_confirm_path
  end
end
