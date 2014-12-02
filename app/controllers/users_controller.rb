class UsersController < ApplicationController
  autocomplete :user, :name, :extra_data => [:profile_photo]

  def index
    scope = policy_scope(User).includes(:profile)
    scope = scope.includes(:memberships).where('memberships IS NULL OR memberships.forum_id != 1').references(:memberships) if params[:forum_id].present?

    if params[:q].present?
      @users = scope.where("lower(username) LIKE lower(?)", "%#{params[:q]}%").page params[:page]
    end
  end

  def edit
    @user = current_user
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
    @user = User.find current_user.id
    authorize @user
    respond_to do |format|
      if @user.update_attributes(permit_params)
        format.html { redirect_to settings_path, notice: "Wijzigingen opgeslagen." }
        format.json { head :no_content }
      else
        fdsas
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
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

  private
  def permit_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end