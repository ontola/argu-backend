class Users::SessionsController < Devise::SessionsController

  # DELETE /resource/sign_out
  def destroy
    super do
      if @current_user.nil? && cookies[:a_a].present?
        cookies[:a_a] = { :value => '-1', :expires => 1.year.ago }
      end
    end
  end

end
