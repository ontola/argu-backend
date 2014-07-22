class OpinionsController < ApplicationController
  load_and_authorize_resource :opinion, :parent => false, except: :allrevisions

  def show
    @parent_id = params[:parent_id].to_s

    @comments = @opinion.root_comments.where(is_trashed: false).page(params[:page]).order('created_at ASC')
    @length = @opinion.root_comments.length

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @opinion }
      format.json { render json: @opinion }
    end
  end

  def new
    @opinion.assign_attributes({pro: %w(con pro).index(params[:pro]), statement_id: params[:statement_id]})
    respond_to do |format|
      if params[:statement_id].present?
        format.html { render :form }
        format.json { render json: @opinion }
      else
        format.html { render text: 'Bad request', status: 400 }
        format.json { head 400 }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html { render :form}
    end
  end

  def create
    respond_to do |format|
      if @opinion.save
        format.html { redirect_to (params[:opinion][:statement_id].blank? ? @opinion : Statement.find_by_id(params[:opinion][:statement_id])), notice: t("opinions.notices.created") }
        format.json { render json: @opinion, status: :created, location: @opinion }
      else
        format.html { render :form, pro: params[:pro], statement_id: params[:opinion][:statement_id] }
        format.json { render json: @opinion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def destroy
  end

private
  def create_params
    params.require(:opinion).permit :title, :content, :statement_id, :pro
  end

  def resource_params
    params.require(:opinion).permit :title, :content, :pro
  end
end
