class QuestionsController < ApplicationController
  def new
    @forum = Forum.friendly.find params[:forum_id]
    @question = Question.new params[:question]
    @question.forum= @forum
    authorize @question
    current_context @question
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @question }
    end
  end

  def create
    @forum = Forum.friendly.find params[:forum_id]
    authorize @forum, :add_question?

    @question = Question.create permit_params
    #@question.creator = current_user
    authorize @question

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: t('type_save_success', type: t('motions.type')) }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render 'form' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @question = Question.find(params[:id])
    authorize @question
    current_context @question
    #@voted = Vote.where(voteable: @question, voter: current_user).last.try(:for) unless current_user.blank?
    @motions = @question.motions

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @question }
      format.json # show.json.jbuilder
    end
  end

private
  def permit_params
    params.require(:question).permit(:id, :title, :content, :tag_list, :forum_id)
  end
end
