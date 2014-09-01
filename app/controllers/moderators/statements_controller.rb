class Moderators::StatementsController < ApplicationController

  # POST /statements/:statement_id/moderator/:user_id
  def create
    @statement = Statement.find_by_id(params[:statement_id])
    authorize! :create_mod, @statement
    @user = User.find_by_id params[:user_id]
    @user.add_role :mod, @statement
    respond_to do |format|
      format.js
      format.json
    end
  end
  # GET /statements/:statement_id/moderators/
  def index
    @statement = Statement.find_by_id(params[:statement_id])
    authorize! :edit_mods, @statement
    @moderators = User.with_role :mod, @statement
  end

  # DELETE /statements/:statement_id/moderators/:user_id
  def destroy
    @statement = Statement.find_by_id params[:statement_id]
    authorize! :destroy_mod, @statement
    user = User.find params[:user_id]
    respond_to do |format|
      if user.remove_role :mod, @statement
        format.js
        format.json
      else
        format.js { head :not_found }
      end
    end
  end

end