class ArgumentsController < ApplicationController

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @argument = Argument.includes(:comment_threads).find params[:id]
    @forum = @argument.forum
    current_context @argument
    authorize @argument, :show?
    @parent_id = params[:parent_id].to_s
    
    @comments = @argument.filtered_threads(show_trashed?)
    @length = @argument.root_comments.length
    @vote = Vote.find_or_initialize_by voteable: @argument, voter: current_profile

    respond_to do |format|
      format.html # show.html.erb
      format.widget { render @argument }
      format.json { render json: @argument }
    end
  end

  # GET /arguments/new
  # GET /arguments/new.json
  def new
    @forum = Forum.find_via_shortname params[:forum_id]
    @argument = @forum.arguments.new motion_id: params[:motion_id]
    authorize @forum, :show?
    if current_profile.blank?
      render_register_modal(nil, [:motion_id, params[:motion_id]], [:pro, params[:pro]])
    else
      authorize @argument, :new?
      current_context @argument
      @argument.assign_attributes({pro: %w(con pro).index(params[:pro]) })

      respond_to do |format|
        if !current_profile.member_of? @argument.forum
          format.js { render partial: 'forums/join', layout: false, locals: { forum: @argument.forum, r: request.fullpath } }
          format.html { render template: 'forums/join', locals: { forum: @argument.forum, r: request.fullpath } }
        elsif params[:motion_id].present?
          format.js { render js: "window.location = #{request.url.to_json}" }
          format.html { render :form }
          format.json { render json: @argument }
        else
          format.html { render text: 'Bad request', status: 400 }
          format.json { head 400 }
        end
      end
    end
  end

  # GET /arguments/1/edit
  def edit
    @argument = Argument.find params[:id]
    authorize @argument, :edit?
    current_context @argument
    @forum = @argument.forum

    respond_to do |format|
      format.html { render :form}
    end
  end

  # POST /arguments
  # POST /arguments.json
  def create
    @forum = Forum.find_via_shortname params[:forum_id]
    @motion = Motion.find params[:argument][:motion_id]
    @argument = @forum.arguments.new motion: @motion
    @argument.attributes= argument_params
    @argument.creator = current_profile
    authorize @argument, :create?

    respond_to do |format|
      if @argument.save
        create_activity @argument, action: :create, recipient: @argument.motion, owner: current_profile, forum_id: @argument.forum.id
        format.html { redirect_to (argument_params[:motion_id].blank? ? @argument : Motion.find_by_id(argument_params[:motion_id])), notice: 'Argument was successfully created.' }
        format.json { render json: @argument, status: :created, location: @argument }
      else
        format.html { render action: 'form', pro: argument_params[:pro], motion_id: argument_params[:motion_id] }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    @argument = Argument.find params[:id]
    authorize @argument, :update?

    respond_to do |format|
      if @argument.update_attributes(argument_params)
        format.html { redirect_to @argument, notice: t('arguments.notices.updated') }
        format.json { head :no_content }
      else
        format.html { render :form }
        format.json { render json: @argument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def destroy
    @argument = Argument.find params[:id]
    if params[:destroy].to_s == 'true'
      authorize @argument, :destroy?
      @argument.destroy
    else
      authorize @argument, :trash?
      @argument.trash
    end

    respond_to do |format|
      format.html { redirect_to motion_path(@argument.motion_id) }
      format.json { head :no_content }
    end
  end

private
  def argument_params
    params.require(:argument).permit(*policy(@argument || Argument).permitted_attributes)
  end

  def self.forum_for(url_options)
    Argument.find_by(url_options[:argument_id] || url_options[:id]).try(:forum)
  end

end
