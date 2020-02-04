# frozen_string_literal: true

module Users
  class IdentitiesController < AuthorizedController
    include RedisResourcesHelper
    skip_before_action :check_if_registered, only: %i[connect attach]
    active_response :connect, :attach, :destroy

    private

    def attach_execute # rubocop:disable Metrics/AbcSize
      connecting_user.r = r_param
      schedule_redis_resource_worker(GuestUser.new(id: session_id), connecting_user, r_param)
      setup_favorites(connecting_user)
      if connection_valid?(connecting_user)
        authenticated_resource.user = connecting_user
        authenticated_resource.save
      else
        connecting_user.errors.add(:password, t('errors.messages.invalid'))
        authenticated_resource.errors.add(:password, t('errors.messages.invalid'))
        false
      end
    end

    def attach_failure
      respond_with_invalid_resource(update_failure_options)
    end

    def attach_success
      flash[:success] = 'Account connected'
      sign_in connecting_user
      redirect_with_r(connecting_user)
    end

    def connect_success
      edit_success
    end

    def connect_success_options
      default_form_options(:connect)
    end

    def connection_valid?(user)
      user.email_addresses.where(email: authenticated_resource.email).exists? &&
        user.valid_password?(params.require(param_key).require(:password))
    end

    def connecting_user
      @connecting_user ||= User.find_via_shortname_or_id!(params[:id].presence || params[param_key][:id])
    end

    def param_key
      @param_key ||= (%w[user identity] & params.keys).first
    end

    def redirect_location
      settings_iri('/u', tab: :authentication)
    end

    def redirect_with_r(user)
      if user.r.present?
        r = user.r
        user.update r: ''
      end
      respond_with_redirect(location: r.presence || root_path)
    end

    def resource_by_id
      return super unless %w[connect attach].include?(action_name)
      payload = decode_token params[:token]
      @identity = Identity.where(user_id: nil).find(payload['identity'])
      @identity.jwt_token = params[:token]
      @identity.connecting_user = connecting_user
      @identity
    end
  end
end
