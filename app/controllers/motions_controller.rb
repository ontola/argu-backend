class MotionsController < ApplicationController

  # GET /motions
  # GET /motions.json
  def index
    @motions = policy_scope(Motion.index(params[:trashed], params[:page]))
    authorize @motions
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @motions }
    end
  end

  # GET /motions/1
  # GET /motions/1.json
  def show
    @motion = Motion.includes(:arguments, :opinions).find(params[:id])
    current_context @motion
    authorize @motion
    @arguments = Argument.ordered @motion.arguments
    @opinions = Opinion.ordered @motion.opinions
    @voted = Vote.where(voteable: @motion, voter: current_profile).last.try(:for) unless current_user.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @motion }
      format.json # show.json.jbuilder
    end
  end

  # GET /motions/new
  # GET /motions/new.json
  def new
    @question = Question.find params[:question_id]
    @motion = Motion.new params[:motion]
    authorize @motion
    current_context @motion
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @motion }
    end
  end

  # GET /motions/1/edit
  def edit
    @motion = Motion.find_by_id(params[:id])
    authorize @motion
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /motions
  # POST /motions.json
  def create
    @question = Question.find params[:question_id]
    @motion = Motion.create permit_params
    @motion.creator = current_profile
    @motion.questions << @question
    authorize @motion
    @motion.forum = current_scope.model

    respond_to do |format|
      if @motion.save
        format.html { redirect_to @motion, notice: t('type_save_success', type: t('motions.type')) }
        format.json { render json: @motion, status: :created, location: @motion }
      else
        format.html { render 'form' }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /motions/1
  # PUT /motions/1.json
  def update
    @motion = Motion.find_by_id params[:id]
    authorize @motion
    respond_to do |format|
      if @motion.update_attributes(permit_params)
        if params[:motion].present? && params[:motion][:tag_id].present? && @motion.tags.reject { |a,b| a.motion==b }.first.present?
          format.html { redirect_to tag_motions_url(Tag.find_by_id(@motion.tag_id).name)}
          format.json { head :no_content }
        else
          format.html { redirect_to @motion, notice: 'Motion was successfully updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render 'form' }
        format.json { render json: @motion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /motions/1
  # DELETE /motions/1.json
  def destroy
    @motion = Motion.find_by_id params[:id]
    if params[:destroy].to_s == 'true'
      authorize @motion
      @motion.destroy
    else
      authorize @motion, :trash?
      @motion.trash
    end

    respond_to do |format|
      format.html { redirect_to motions_url }
      format.json { head :no_content }
    end
  end

private
  def permit_params
    params.require(:motion).permit(:id, :title, :content, :arguments, :statetype, :tag_list, :invert_arguments, :tag_id)
  end
end
