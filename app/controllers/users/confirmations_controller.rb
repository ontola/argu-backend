class Users::ConfirmationsController < Devise::ConfirmationsController
  skip_filter :require_no_authentication, only: :create, if: :correct_mail

  def create
    super
  end

  protected

  def after_resending_confirmation_instructions_path_for(resource)
    if correct_mail
      request.headers['Referer']
    else
      super
    end
  end

  def correct_mail
    current_user.present? ? params[:user][:email] == current_user.email : true
  end

end
