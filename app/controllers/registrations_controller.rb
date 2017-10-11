# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_scope!, only: :destroy
  include RedisResourcesHelper
  include OauthHelper
  include NestedResourceHelper
  respond_to :json

  skip_before_action :verify_authenticity_token,
                     if: -> { headers['Authorization'].blank? && cookies[Rails.configuration.cookie_name].blank? }

  def create
    super do |resource|
      unless resource.persisted?
        send_event user: resource,
                   category: 'registrations',
                   action: 'create',
                   label: 'failed'
      end
    end
    session[:omniauth] = nil unless @user.new_record?
  end

  def cancel
    if current_user.guest?
      flash[:error] = 'Not signed in'
      redirect_to root_path
    else
      @user = current_user
      render 'cancel'
    end
  end

  def destroy
    @user = User.find current_user.id
    authorize @user, :destroy?
    unless params[:user][:confirmation_string] == t('users_cancel_string')
      @user.errors.add(:confirmation_string, t('errors.messages.should_match'))
    end
    respond_to do |format|
      if @user.errors.empty? && @user.destroy
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
        send_event category: 'registrations',
                   action: 'destroy',
                   label: @user.id
        format.html { redirect_to root_path, status: 303, notice: t('type_destroy_success', type: 'Account') }
        format.json { respond_with_204(@user, :json) }
        format.json_api { respond_with_204(@user, :json_api) }
      else
        format.html { render action: 'cancel' }
        format.json { respond_with_422(@user, :json) }
        format.json_api { respond_with_422(@user, :json_api) }
      end
    end
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
    send_confirmation_mail(
      resource,
      session.presence && RedisResource::Relation
                            .where(publisher: GuestUser.new(id: session.id), voteable_type: 'Motion')
    )
    schedule_redis_resource_worker(GuestUser.new(id: session.id), resource, resource.r) if session.present?
    setup_favorites(resource)
    send_event user: resource,
               category: 'registrations',
               action: 'create',
               label: 'email'
  end

  private

  def build_resource(*args)
    super
    resource.shortname = nil if resource.shortname.shortname.blank?
    resource.build_profile
    resource.language = I18n.locale
    return unless session[:omniauth]
    @user.apply_omniauth(session[:omniauth])
    @user.valid?
  end

  def send_confirmation_mail(user, guest_votes)
    if guest_votes&.count&.positive?
      api.create_email(
        :ConfirmationsMailer,
        :confirm_votes,
        user,
        confirmationToken: user.confirmation_token,
        motions: guest_votes.map do |guest_vote|
          m = guest_vote.resource.parent_model(:motion)
          {display_name: m.display_name, url: m.context_id, option: guest_vote.resource.for}
        end
      )
    elsif resource.password.present?
      api.create_email(:ConfirmationsMailer, :confirmation, user, confirmationToken: user.confirmation_token)
    else
      token = user.send(:set_reset_password_token)
      api.create_email(:ConfirmationsMailer, :set_password, user, passwordToken: token)
    end
  end
end
