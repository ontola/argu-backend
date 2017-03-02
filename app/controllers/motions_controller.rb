# frozen_string_literal: true
class MotionsController < AuthorizedController
  include NestedResourceHelper
  skip_before_action :check_if_registered, only: :index

  def index
    skip_verify_policy_scoped(true)
    respond_to do |format|
      format.json_api do
        render json: get_parent_resource.motion_collection(collection_options),
               include: INC_NESTED_COLLECTION
      end
    end
  end

  def search
    if params[:q].present? && params[:thing].present?
      @motions = policy_scope(Motion).search(params[:q])
      render json: @motions.present? ? @motions : {data: []}
    else
      skip_verify_policy_scoped(true)
      errors = []
      errors << {title: 'Query parameter `q` not present'} unless params[:q].present?
      errors << {title: 'Type parameter `thing` not present'} unless params[:thing].present?
      render status: 400,
             json: {errors: errors}
    end
  end

  # GET /motions/1
  # GET /motions/1.json
  def show
    @arguments = Argument.ordered(
      policy_scope(authenticated_resource.arguments.show_trashed(show_trashed?).includes(:votes)),
      pro: show_params[:page_arg_pro],
      con: show_params[:page_arg_con]
    )
    unless current_user.blank?
      @vote = Vote.where(
        voteable_id: authenticated_resource.id,
        voteable_type: 'Motion',
        creator: current_profile
      ).last
    end
    @vote ||= Vote.new(
      voteable_id: authenticated_resource.id,
      voteable_type: authenticated_resource.class.name,
      creator: current_profile
    )
    authenticated_resource.current_vote = @vote

    respond_to do |format|
      format.html { render locals: {motion: authenticated_resource} }
      format.widget { render authenticated_resource }
      format.json # show.json.jbuilder
      format.json_api do
        render json: authenticated_resource,
               include: [
                 argument_collection: INC_NESTED_COLLECTION,
                 attachment_collection: INC_NESTED_COLLECTION,
                 vote_event_collection: {members: {vote_collection: INC_NESTED_COLLECTION}}
               ]
      end
    end
  end

  # GET /motions/new
  # GET /motions/new.json
  def new
    authorize authenticated_resource, :new?
    respond_to do |format|
      format.js { render js: "window.location = #{request.url.to_json}" }
      format.html { render 'form', locals: {motion: authenticated_resource} }
      format.json { render json: authenticated_resource }
    end
  end

  # GET /motions/1/edit
  def edit
    @motion = authenticated_resource
    authorize @motion
    respond_to do |format|
      format.html { render 'form', locals: {motion: @motion} }
    end
  end

  # POST /motions
  # POST /motions.json
  def create
    create_service.on(:create_motion_successful) do |motion|
      respond_to do |format|
        first = current_profile.motions.count == 1 || nil
        format.html do
          redirect_to motion_path(motion, start_motion_tour: first),
                      notice: t('type_save_success', type: motion_type)
        end
        format.json { render json: motion, status: :created, location: motion }
        format.json_api { render json: motion, status: :created, location: motion }
      end
    end
    create_service.on(:create_motion_failed) do |motion|
      respond_to do |format|
        format.html { render 'form', locals: {motion: motion} }
        format.json { render json: motion.errors, status: :unprocessable_entity }
        format.json_api { render json_api_error(422, motion.errors) }
      end
    end
    create_service.commit
  end

  # PUT /motions/1
  # PUT /motions/1.json
  def update
    update_service.on(:update_motion_successful) do |motion|
      respond_to do |format|
        if params[:motion].present? &&
            params[:motion][:tag_id].present? &&
            motion.tags.reject { |a, b| a.motion == b }.first.present?
          format.html { redirect_to tag_motions_url(Tag.find_by_id(motion.tag_id).name) }
        else
          format.html { redirect_to motion, notice: t('type_save_success', type: motion_type) }
        end
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
    update_service.on(:update_motion_failed) do |motion|
      respond_to do |format|
        format.html { render 'form', locals: {motion: motion} }
        format.json { render json: motion.errors, status: :unprocessable_entity }
        format.json_api { render json_api_error(422, motion.errors) }
      end
    end
    update_service.commit
  end

  # DELETE /motions/1?destroy=true
  # DELETE /motions/1.json?destroy=true
  def destroy
    destroy_service.on(:destroy_motion_successful) do |motion|
      parent = motion.edge.parent.owner
      respond_to do |format|
        format.html { redirect_to parent, notice: t('type_destroy_success', type: t('motions.type')) }
        format.json { head :no_content }
      end
    end
    destroy_service.on(:destroy_motion_failed) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('errors.general') }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    destroy_service.commit
  end

  # DELETE /motions/1
  # DELETE /motions/1.json
  def trash
    trash_service.on(:trash_motion_successful) do |motion|
      parent = motion.edge.parent.owner
      respond_to do |format|
        format.html { redirect_to parent, notice: t('type_trash_success', type: t('motions.type')) }
        format.json { head :no_content }
      end
    end
    trash_service.on(:trash_motion_failed) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('errors.general') }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    trash_service.commit
  end

  # PUT /motions/1/untrash
  # PUT /motions/1/untrash.json
  def untrash
    untrash_service.on(:untrash_motion_successful) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('type_untrash_success', type: t('motions.type')) }
        format.json { head :no_content }
      end
    end
    untrash_service.on(:untrash_motion_failed) do |motion|
      respond_to do |format|
        format.html { redirect_to motion, notice: t('errors.general') }
        format.json { render json: motion.errors, status: :unprocessable_entity }
      end
    end
    untrash_service.commit
  end

  # GET /motions/1/move
  def move
    authorize authenticated_resource, :move?

    respond_to do |format|
      format.html { render locals: {resource: authenticated_resource} }
      format.js { render locals: {resource: authenticated_resource} }
    end
  end

  def move!
    authorize authenticated_resource, :move?
    @forum = Forum.find permit_params[:forum_id]
    authorize @forum, :update?
    moved = false
    authenticated_resource.with_lock do
      moved = authenticated_resource.move_to @forum
    end
    if moved
      redirect_to motion_url(authenticated_resource)
    else
      redirect_to edit_motion_url authenticated_resource
    end
  end

  def forum_for(url_options)
    motion_id = url_options[:motion_id] || url_options[:id]
    if motion_id.presence
      Motion.find_by(id: motion_id).try(:forum)
    elsif url_options[:forum_id].present?
      Forum.find_via_shortname_nil url_options[:forum_id]
    end
  end

  private

  def show_params
    params.permit(:page, :page_arg_pro, :page_arg_con)
  end

  def resource_new_params
    if get_parent_resource.try(:project).present?
      super.merge(project: get_parent_resource.project)
    else
      super
    end
  end
end
