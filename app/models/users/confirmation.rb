# frozen_string_literal: true

module Users
  class Confirmation < VirtualResource
    include LinkedRails::Model
    enhance LinkedRails::Enhancements::Actionable
    enhance LinkedRails::Enhancements::Creatable, except: %i[Controller]
    attr_accessor :current_user, :email, :token, :user, :password_token

    def confirm!
      return false unless email&.confirm

      set_reset_password_token if reset_password?

      true
    end

    def iri_template_name
      :confirmations_iri
    end

    def iri_opts
      {confirmation_token: token}
    end

    alias identifier class_name

    def new_record?
      true
    end

    def redirect_url
      return if current_user != user
      return @redirect_url if @redirect_url

      return @redirect_url = ActsAsTenant.current_tenant.iri unless password_token

      @redirect_url = iri_from_template(:user_set_password, reset_password_token: password_token)
    end

    private

    def reset_password?
      user.present? && user.encrypted_password.blank?
    end

    def set_reset_password_token
      self.password_token = user.send(:set_reset_password_token)
    end
  end
end
