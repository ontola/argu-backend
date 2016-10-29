# frozen_string_literal: true
class ArgumentsController < AuthorizedController
  include NestedResourceHelper

  def index
    parent_resource = Motion.includes(:arguments).find(params[:motion_id])
    collection = Collection.new(
      id: url_for([parent_resource, :arguments]),
      parent: get_parent_resource,
      association: :arguments,
      collection_entries: policy_scope(parent_resource.arguments)
    )
    respond_to do |format|
      format.json_api do
        render json: collection, include: {collection_entries: collection.collection_entries}
      end
    end
  end

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @comments = authenticated_resource.filtered_threads(show_trashed?, params[:page])
    @length = authenticated_resource.root_comments.length
    @vote = Vote.find_by(voteable: authenticated_resource, voter: current_profile)

    respond_to do |format|
      format.html do
        render locals: {
          argument: authenticated_resource,
          comment: Comment.new
        }
      end
      format.widget do
        render authenticated_resource,
               locals: {argument: authenticated_resource}
      end
      format.json { render json: authenticated_resource }
      format.json_api { render json: authenticated_resource }
    end
  end

  # GET /arguments/new
  # GET /arguments/new.json
  def new
    authenticated_resource!.assign_attributes(pro: %w(con pro).index(params[:pro]))

    respond_to do |format|
      if params[:motion_id].present?
        format.js { render js: "window.location = #{request.url.to_json}" }
        format.html { render :form, locals: {argument: authenticated_resource!} }
        format.json { render json: authenticated_resource! }
      else
        format.html { render text: 'Bad request', status: 400 }
        format.json { head 400 }
      end
    end
  end

  # GET /arguments/1/edit
  def edit
    respond_to do |format|
      format.html { render :form }
    end
  end

  # POST /arguments
  # POST /arguments.json
  def create
    create_service.on(:create_argument_successful) do |argument|
      respond_to do |format|
        argument = permit_params[:motion_id].blank? ? argument : argument.motion
        format.html { redirect_to argument, notice: t('arguments.notices.created') }
        format.json { render json: argument, status: :created, location: argument }
      end
    end
    create_service.on(:create_argument_failed) do |argument|
      respond_to do |format|
        format.html { render action: 'form', locals: {argument: argument} }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    create_service.commit
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    update_service.on(:update_argument_successful) do |argument|
      respond_to do |format|
        format.html { redirect_to argument, notice: t('arguments.notices.updated') }
        format.json { head :no_content }
      end
    end
    update_service.on(:update_argument_failed) do |argument|
      respond_to do |format|
        format.html { render :form }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    update_service.commit
  end

  # DELETE /arguments/1?destroy=true
  # DELETE /arguments/1.json?destroy=true
  def destroy
    destroy_service.on(:destroy_argument_successful) do |argument|
      respond_to do |format|
        format.html do
          redirect_to motion_path(argument.motion_id),
                      notice: t('type_destroy_success', type: t('arguments.type'))
        end
        format.json { head :no_content }
      end
    end
    destroy_service.on(:destroy_argument_failed) do |argument|
      respond_to do |format|
        format.html { redirect_to argument, notice: t('errors.general') }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    destroy_service.commit
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def trash
    trash_service.on(:trash_argument_successful) do |argument|
      respond_to do |format|
        format.html do
          redirect_to motion_path(argument.motion_id),
                      notice: t('type_trash_success', type: t('arguments.type'))
        end
        format.json { head :no_content }
      end
    end
    trash_service.on(:trash_argument_failed) do |argument|
      respond_to do |format|
        format.html { redirect_to argument, notice: t('errors.general') }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    trash_service.commit
  end

  # PUT /arguments/1/untrash
  # PUT /arguments/1/untrash.json
  def untrash
    untrash_service.on(:untrash_argument_successful) do |argument|
      respond_to do |format|
        format.html { redirect_to argument, notice: t('type_untrash_success', type: t('arguments.type')) }
        format.json { head :no_content }
      end
    end
    untrash_service.on(:untrash_argument_failed) do |argument|
      respond_to do |format|
        format.html { redirect_to argument, notice: t('errors.general') }
        format.json { render json: argument.errors, status: :unprocessable_entity }
      end
    end
    untrash_service.commit
  end

  def forum_for(url_options)
    argument_id = url_options[:argument_id] || url_options[:id]
    if argument_id.presence
      Argument.find_by(id: argument_id).try(:forum)
    elsif url_options[:forum_id].present?
      Forum.find_via_shortname_nil url_options[:forum_id]
    end
  end

  private

  def authenticated_resource!
    return super unless params[:action] == 'index'
    get_parent_resource
  end

  def get_parent_resource(opts = request.path_parameters, url_params = params)
    return super unless %w(new create index).include?(params[:action])
    Motion.find(params[:motion_id] || params[:argument][:motion_id])
  end

  def resource_new_params
    super.merge(motion_id: params[:motion_id])
  end

  def service_options(opts = {})
    super(opts.merge(auto_vote:
                       params.dig(:argument, :auto_vote) == 'true' &&
                         current_profile == current_user.profile))
  end
end
