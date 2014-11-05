class StatementsController < ApplicationController

  # GET /statements
  # GET /statements.json
  def index
    @statements = policy_scope(Statement.index(params[:trashed], params[:page]))
    authorize @statements
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statements }
    end
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
    @statement = Statement.includes(:arguments, :opinions).find(params[:id])
    authorize @statement
    @arguments = @statement.arguments.group_by { |a| a.key }
    @opinions = @statement.opinions.group_by { |a| a.key }
    @voted = Vote.where(voteable: @statement, voter: current_user).last.try(:for) unless current_user.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @statement }
      format.json # show.json.jbuilder
    end
  end

  # GET /statements/new
  # GET /statements/new.json
  def new
    @question = Question.find params[:question_id]
    @statement = Statement.new params[:statement]
    authorize @statement
    respond_to do |format|
      format.html { render 'form' }
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/edit
  def edit
    @statement = Statement.find_by_id(params[:id])
    authorize @statement
    respond_to do |format|
      format.html { render 'form' }
    end
  end

  # POST /statements
  # POST /statements.json
  def create
    @question = Question.find params[:question_id]
    @statement = Statement.create permit_params
    @statement.creator = current_user.profile
    @statement.questions << @question
    authorize @statement
    @statement.organisation = current_user._current_scope
    #current_user.profile.add_role :mod, @statement

    respond_to do |format|
      if @statement.save
        format.html { redirect_to @statement, notice: t('type_save_success', type: t('statements.type')) }
        format.json { render json: @statement, status: :created, location: @statement }
      else
        format.html { render 'form' }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /statements/1
  # PUT /statements/1.json
  def update
    @statement = Statement.find_by_id params[:id]
    authorize @statement
    respond_to do |format|
      if @statement.update_attributes(permit_params)
        if params[:statement].present? && params[:statement][:tag_id].present? && @statement.tags.reject { |a,b| a.statement==b }.first.present?
          format.html { redirect_to tag_statements_url(Tag.find_by_id(@statement.tag_id).name)}
          format.json { head :no_content }
        else
          format.html { redirect_to @statement, notice: 'Statement was successfully updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render 'form' }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement = Statement.find_by_id params[:id]
    if params[:destroy].to_s == 'true'
      authorize @statement
      @statement.destroy
    else
      authorize @statement, :trash?
      @statement.trash
    end

    respond_to do |format|
      format.html { redirect_to statements_url }
      format.json { head :no_content }
    end
  end

private
  def permit_params
    params.require(:statement).permit(:id, :title, :content, :arguments, :statetype, :tag_list, :invert_arguments, :tag_id)
  end
end
