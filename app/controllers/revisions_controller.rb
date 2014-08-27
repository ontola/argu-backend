class RevisionsController < ApplicationController

  # GET /resource/1/revisions
  # GET /resource/1/revisions.json
  def index
    @statement = Statement.where(id: params[:statement_id], arguments: {is_trashed: true}).includes(:arguments).first
    @revisions = @statement.versions.scoped.reject{ |v| v.object.nil? }.reverse
    @arguments = @statement.arguments.where(is_trashed: true).plusminus_tally({order: "vote_count ASC"}).group_by { |a| a.key }

    authorize! :allrevisions, @statement
    respond_to do |format|
      format.html # allrevisions.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/revisions/:rev
  # GET /statements/1/revisions/:rev.json
  def show
    @statement = Statement.find_by_id(params[:statement_id])
    @version = nil

    unless (@rev = params[:rev]).nil?
      @version = @statement.versions.find_by_id(@rev)
      @statement = @version.reify
    end
    @statement ||= @statement.versions.last

    authorize! :revisions, @statement
    respond_to do |format|
      format.html # revisions.html.erb
      format.json { render json: @statement }
    end
  end

  # PUT /statements/1/revisions
  # PUT /statements/1/revisions.json
  def update
    @statement = Statement.find_by_id(params[:statement_id])
    @version = nil

    unless (@rev = params[:rev]).nil?
      @version = @statement.versions.find_by_id(@rev);
      @statement = @version.reify
    end
    @statement ||= @statement.versions.last if @statement.nil?

    authorize :setrevision, @statement
    respond_to do |format|
      if @statement.save
        format.html { redirect_to @statement, notice: 'Statement was successfully restored.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end  

private
  def permit_params
    params.require(:statement).permit(:id, :title, :content, :arguments, :statetype, :tag_list, :invert_arguments, :tag_id)
  end
end
