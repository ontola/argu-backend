class ApplicationController < ActionController::Base
  include Pundit, ActorsHelper, ApplicationHelper, ConvertibleHelper, PublicActivity::StoreController,
          AccessTokenHelper, AlternativeNamesHelper, UsersHelper, GroupResponsesHelper
  helper_method :current_profile, :current_context, :current_scope, :show_trashed?
  protect_from_forgery with: :exception
  prepend_before_action :check_for_access_token
  before_action :check_finished_intro
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_layout
  before_action :set_locale
  after_action :verify_authorized, :except => :index, :unless => :devise_controller?
  after_action :verify_policy_scoped, :only => :index
  after_action :set_profile_forum
  around_action :set_time_zone
  #after_action :set_notification_header
  if Rails.env.development? || Rails.env.staging?
    before_action do
      if current_user && current_user.profile.has_role?(:staff)
        Rack::MiniProfiler.authorize_request
      end
    end
  end

  rescue_from ActiveRecord::RecordNotUnique, with: lambda {
    flash[:warning] = t(:twice_warning)
    redirect_to :back
  }

  rescue_from Pundit::NotAuthorizedError do |exception|
    @_not_authorized_caught = true
    Rails.logger.error exception
    action = exception.query.to_s[0..-2]
    error = t("#{exception.record.try(:class_name)}.pundit.#{action}",
              action: "#{exception.record.class}##{action}",
              default: t('access_denied'))
    respond_to do |format|
      format.js { render status: 403, json: { notifications: [{type: :error, message: error }] } }
      format.json { render status: 403, json: { notifications: [{type: :error, message: error }] } }
      format.html {
        redirect_location = if defined?(authenticated_context) && authenticated_context.present?
          url_for(authenticated_context)
        elsif request.env['HTTP_REFERER'].present? && request.env['HTTP_REFERER'] != request.original_url
          request.env['HTTP_REFERER']
        else
          root_path
        end
        redirect_to redirect_location, alert: error
      }
    end
  end

  rescue_from Argu::NotLoggedInError do |exception|
    @_not_logged_in_caught = true
    respond_to do |format|
      format.js { render status: 401, json: { notifications: [{type: :error, message: t("pundit.#{exception.policy.class.to_s.underscore}.#{exception.query}") }] } }
      format.html {
        @resource ||= User.new r: exception.r
        render 'devise/sessions/new',
               locals: {
                   resource: @resource,
                   resource_name: :user,
                   devise_mapping: Devise.mappings[:user],
                   r: exception.r, preview: exception.preview
               }
      }
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    @quote = (Setting.get(:quotes) || '').split(';').sample
    @additional_error_info = exception.to_s
    respond_to do |format|
      format.html { render 'status/404', status: 404 }
      format.js { head 404 }
      format.json { render json: { title: t('status.s_404.header'), message: t('status.s_404.body'), quote: @quote}, status: 404 }
    end
  end

  rescue_from ActionController::ParameterMissing do |exception|
    @additional_error_info = exception.to_s
    respond_to do |format|
      format.html { render 'status/400', status: 400 }
      format.json { render json: { title: t('status.s_400.header'), message: t('status.s_400.body'), quote: @quote}, status: 400 }
      format.js { head 400 }
    end
  end

  rescue_from ActiveRecord::StaleObjectError, with: :rescue_stale
  rescue_from Redis::ConnectionError do |e|
    Redis.rescue_redis_connection_error(e)
  end

  def after_sign_in_path_for(resource)
    if params[:host_url].present? && params[:host_url] == 'argu.freshdesk.com'
      freshdesk_redirect_url
    else
      super
    end
  end

  # Combines {ApplicationController#create_activity} with {ApplicationController#destroy_recent_similar_activities}
  def create_activity_with_cleanup(model, params)
    destroy_recent_similar_activities model, params
    create_activity model, params
  end

  # Creates an {Activity} for a model asynchronously
  # @param [ActiveRecord::Base] model a model to create the {Activity} for
  # @param [Hash] params options for {PublicActivity::Common#create_activity}
  def create_activity(model, params)
    a = model.create_activity params
  end
  deprecate :create_activity

  def current_scope
    @current_scope ||= (current_context.context_scope(current_profile) || current_context)
  end

  # @return [Context] The current context, if a param is given, it will serve as the start of the current context
  def current_context(model=nil)
    @current_context ||= Context.parse_from_uri(request.url, model) do |components|
      components.reject! { |c| !policy(c).show? }
    end
  end

  # @return [Profile, nil] The {Profile} the {User} is using to do actions
  def current_profile
    if current_user.present?
      @current_profile ||= get_current_actor
    else
      nil
    end
  end

  # Deletes all other activities created within 6 hours of the new activity.
  def destroy_recent_similar_activities(model, params)
    Activity.delete Activity.where('created_at >= :date', :date => 6.hours.ago).where(trackable_id: model.id, owner_id: params[:owner].id, key: "#{model.class.name.downcase}.create").pluck(:id)
  end

  def forum_by_geocode
    if session[:geo_location].present?
      forum = Forum.find_via_shortname_nil(session[:geo_location].city.downcase) if session[:geo_location].city.present?
      forum ||= Forum.find_via_shortname_nil(session[:geo_location].country.downcase) if session[:geo_location].country.present?
      forum = Forum.find_via_shortname_nil('eu') if forum.blank? && EU_COUNTRIES.include?(session[:geo_location].country_code)
      forum
    end
  end

  # Uses Redis to fetch the {User}s last visited {Forum}, if not present uses {Forum.first_public}
  def preferred_forum(profile = nil)
    profile ||= current_profile
    if profile.present?
      preferred = profile.preferred_forum
      if preferred && policy(preferred).show?
        preferred
      else
        profile.memberships.first.try(:forum) || Forum.first_public
      end
    else
      last_forum = Argu::Redis.get("session:#{session.id}:last_forum")
      (Forum.find_by(id: last_forum) if last_forum.present?) || Forum.first_public
    end
  end

  # @private
  def pundit_user
    UserContext.new(current_user,
                    current_profile,
                    session,
                    @forum,
                    {
                        platform_open: platform_open?,
                        within_user_cap: within_user_cap?
                    })
  end

  def rescue_stale
    respond_to do |format|
      format.html {
        correct_stale_record_version
        stale_record_recovery_action
      }
      format.xml  { head :conflict }
      format.json { head :conflict }
    end
  end

  # @private
  def set_locale
    I18n.locale = current_user.try(:language) || http_accept_language.compatible_language_from(I18n.available_locales)
  end

  # @private
  def set_notification_header
    if current_user.present?
      response.headers[:lastNotification] = policy_scope(Notification).order(created_at: :desc).limit(1).pluck(:created_at)[0] || '-1'
    else
      response.headers[:lastNotification] = '-1'
    end
  end

  def set_profile_forum
    if instance_variable_defined?(:@forum) && @forum.is_a?(Forum) && current_profile.present?
      Argu::Redis.set("profile:#{current_profile.id}:last_forum", @forum.id)
    elsif instance_variable_defined?(:@forum) && @forum.is_a?(Forum)
      Argu::Redis.setex("session:#{session.id}:last_forum", 1.day.seconds.to_i, @forum.id)
    end
  end

  def set_time_zone(&block)
    time_zone = current_user.try(:time_zone) || 'Amsterdam'
    Time.use_zone(time_zone, &block)
  end

  # Has the {User} enabled the `trashed` `param` and is he authorized?
  def show_trashed?
    if params[:trashed].present? && policy(current_scope.model).update?
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
    devise_parameter_sanitizer.for(:sign_up) << [:email, :r, :access_tokens, shortname_attributes: [:shortname]]
    devise_parameter_sanitizer.for(:sign_in) << [:r]
    devise_parameter_sanitizer.for(:accept_invitation).concat [shortname_attributes: [:shortname]]
  end

  # @private
  # Before_action which redirects the {User} if he didn't finish the intro.
  def check_finished_intro
    if current_user
      if current_user.url.blank?
        redirect_to setup_users_path if request.original_url != setup_users_url
      elsif !current_user.finished_intro? && !request.original_url.in?(intro_urls)
        if current_user.first_name.present?
          redirect_to selector_forums_url
        else
          redirect_to edit_user_url(current_user.url)
        end
      end
    end
  end

  # @private
  def intro_urls
    [selector_forums_url, profile_url(current_user), edit_user_url(current_user), memberships_forums_url]
  end

  # @private
  # Determines what layout the {User} should see.
  def set_layout
    if request.headers['X-PJAX']
      self.class.layout false
    elsif current_user.present? && current_user.finished_intro? && current_user.url.present?
      self.class.layout 'application'
    elsif current_user.present? && current_user.url.blank?
      self.class.layout 'closed'
    elsif has_valid_token?
      self.class.layout 'guest'
    else
      self.class.layout 'guest'
    end
  end

  def stale_record_recovery_action
    flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
    render :edit, :status => :conflict
  end

  # @private
  # For Devise
  def after_sending_reset_password_instructions_path_for(resource_name)
    password_reset_confirm_path
  end

  private

  def naming_context
    current_context.context_scope(current_profile).root_parent.model
  end
end
