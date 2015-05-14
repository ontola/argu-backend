class OpinionsController < ApplicationController

  def show
    @opinion = Opinion.includes(:comment_threads).find params[:id]
    authorize @opinion
    @parent_id = params[:parent_id].to_s

    @comments = @opinion.comment_threads.where(:parent_id => nil, is_trashed: false).page(params[:page]).order('created_at ASC')
    @length = @opinion.root_comments.length

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @opinion }
      format.json { render json: @opinion }
    end
  end

  def new
    @opinion = Opinion.new
    authorize @opinion
    @opinion.assign_attributes({pro: %w(con pro).index(params[:pro]), motion_id: params[:motion_id]})

    respond_to do |format|
      if params[:motion_id].present?
        format.html { render :form }
        format.json { render json: @opinion }
      else
        format.html { render text: 'Bad request', status: 400 }
        format.json { head 400 }
      end
    end
  end

  def edit
    @opinion = Opinion.find params[:id]
    authorize @opinion

    respond_to do |format|
      format.html { render :form}
    end
  end

  def create
    @opinion = Opinion.new create_params
    @opinion.creator = current_user
    authorize @opinion
    @opinion.motion_id = create_params[:motion_id]
    @opinion.pro = create_params[:pro]

    respond_to do |format|
      if @opinion.save
        format.html { redirect_to (params[:opinion][:motion_id].blank? ? @opinion : Motion.find_by_id(params[:opinion][:motion_id])), notice: t('opinions.notices.created') }
        format.json { render json: @opinion, status: :created, location: @opinion }
      else
        format.html { render :form, pro: params[:pro], motion_id: params[:opinion][:motion_id] }
        format.json { render json: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @opinion = Opinion.find params[:id]
    authorize @opinion

    respond_to do |format|
      if @opinion.update_attributes(resource_params)
        format.html { redirect_to @opinion, notice: t('arguments.notices.updated') }
        format.json { head :no_content }
      else
        format.html { render :form }
        format.json { render json: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @opinion = Opinion.find params[:id]
    if params[:destroy].to_s == 'true'
      authorize @argument
      @opinion.destroy
    else
      authorize @opinion, :trash?
      @opinion.trash
    end

    respond_to do |format|
      format.html { redirect_to motion_path(@opinion.motion_id) }
      format.json { head :no_content }
    end
  end

private
  def create_params
    params.require(:opinion).permit :title, :content, :motion_id, :pro
  end

  def resource_params
    params.require(:opinion).permit :title, :content, :pro
  end
end
