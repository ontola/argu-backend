class ForumsController < ApplicationController
  def show
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :show?
    current_context @forum
  end



  def settings
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?
    current_context @forum
  end

  def update
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?

    if @forum.update permit_params
      redirect_to settings_forum_path(@forum, tab: params[:tab])
    else
      render 'settings'
    end
  end

  def delete
  end

  def destroy
  end

private
  def permit_params
    params.require(:forum).permit(*policy(@forum || Forum).permitted_attributes)
  end
end
