class UsersController < ApplicationController
  autocomplete :user, :name, :extra_data => [:profile_photo]

  def edit
    @user = User.find current_user.id
    authorize @user

    unless @user.nil?
      @authentications = @user.authentications
      respond_to do |format|
        format.html
        format.json { render json: @user }
      end
    else
      flash['User not found']
      request.env['HTTP_REFERER'] ||= root_path
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render json: "Error: user not found" }
      end
    end
  end

  # PUT /settings
  def update
    @user = current_user unless current_user.blank?
    authorize @user

    respond_to do |format|
      if @user.update_attributes(params[:user]) && @user.profile.update_attributes(params[:profile])
        format.html { redirect_to settings_path, notice: "Wijzigingen opgeslagen." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.jsoon { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /users/search/:username
  # POST /users/search
  def search
    #@users = User.where(User.arel_table[:username].matches("%#{params[:username]}%")) if params[:username].present?
    @users = User.search do
      fulltext params['username']
      paginate page: params[:page]
    end.results unless params['username'].blank?
    respond_to do |format|
        format.js { render partial: params[:c].present? ? params[:c] + '/search' : 'search' }
        format.json { render json: @users }
    end
  end
end