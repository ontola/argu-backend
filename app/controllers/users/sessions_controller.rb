class Users::SessionsController < Devise::SessionsController

  def create
    if params[:user][:r].present?
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      r = r_with_authenticity_token(params[:user][:r] || '')
      resource.update r: ''
      redirect_to r, status: is_post?(r) ? 307 : 302
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

  private

  def r_with_authenticity_token(r)
    uri = URI.parse(r)
    query = URI.decode_www_form(uri.query || '')
    query << ['authenticity_token', form_authenticity_token] if is_post?(r)
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end

  def is_post?(r)
    r.match(/\/v(\?|\/)|\/c(\?|\/)/)
  end

end
