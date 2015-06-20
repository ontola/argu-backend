class Users::IdentitiesController < ApplicationController

  def destroy
    @identity = Identity.find params[:id]
    authorize @identity, :destroy?

    respond_to do |format|
      if @identity.destroy
        flash[:success] = t('devise.authentications.destroyed')
      else
        flash[:error] = t('devise.authentications.destroyed_failed')
      end
      format.html { redirect_to settings_path }
    end
  end

end
