class QuestionsController < ApplicationController
  def new
    @organisation = Organisation.find params[:organisation_id]
    @question = Question.new params[:question]
    authorize @question
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @question }
    end
  end

  def create
    @organisation = Organisation.find params[:organisation_id]
    authorize @organisation, :add_question?

    @question = Question.create permit_params
    #@question.creator = current_user
    authorize @question

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: t('type_save_success', type: t('statements.type')) }
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
    params.require(:question).permit(:id, :title, :content, :tag_list, :organisation_id)
  end
end
