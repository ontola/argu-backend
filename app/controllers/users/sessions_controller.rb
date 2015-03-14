class Users::SessionsController < Devise::SessionsController

  def create
    if params[:user][:r].present?
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      r = params[:user][:r]
      resource.update r: ''
      redirect_to r, status: r.match(/vote|comments/) ? 307 : 302
    else
      super
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super do
      if @current_user.nil? && cookies[:a_a].present?
        cookies[:a_a] = { :value => '-1', :expires => 1.year.ago }
      end
    end
  end

end
