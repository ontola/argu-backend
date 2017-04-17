# frozen_string_literal: true
class ArgumentsController < EdgeTreeController
  skip_before_action :check_if_registered, only: :index

  # GET /arguments/1
  # GET /arguments/1.json
  def show
    @comments = authenticated_resource.filtered_threads(show_trashed?, params[:page])
    @length = authenticated_resource.root_comments.length
    @vote = Vote.find_by(
      voteable_id: authenticated_resource.id,
      voteable_type: 'Argument',
      creator: current_profile
    )

    respond_to do |format|
      format.html do
        render locals: {
          argument: authenticated_resource,
          comment: Edge.new(owner: Comment.new, parent: authenticated_resource.edge).owner
        }
      end
      format.widget do
        render authenticated_resource,
               locals: {argument: authenticated_resource}
      end
      format.json { render json: authenticated_resource }
      format.json_api do
        render json: authenticated_resource,
               include: [
                 comment_collection: INC_NESTED_COLLECTION
               ]
      end
    end
  end

  # PUT /arguments/1
  # PUT /arguments/1.json
  def update
    update_service.on(:update_argument_successful) do |argument|
      respond_to do |format|
        format.html { redirect_to argument, notice: t('arguments.notices.updated') }
        format.json { head :no_content }
        format.json_api { head :no_content }
      end
    end
    update_service.on(:update_argument_failed) do |argument|
      respond_to do |format|
        format.html { render :form }
        format.json { render json: argument.errors, status: :unprocessable_entity }
        format.json_api { render json_api_error(422, argument.errors) }
      end
    end
    update_service.commit
  end

  # DELETE /arguments/1
  # DELETE /arguments/1.json
  def trash
    trash_service.on(:trash_argument_successful) do |argument|
      respond_to do |format|
        format.html do
          redirect_to argument.parent_model,
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

  def deserialize_params_options
    {keys: {name: :title, text: :content}}
  end

  def new_respond_blocks_success(resource, format)
    resource.assign_attributes(pro: %w(con pro).index(params[:pro]))
    return super if params[:motion_id].present?
    format.html { render text: 'Bad request', status: 400 }
    format.json { head 400 }
  end

  def service_options(opts = {})
    super(opts.merge(auto_vote:
                       params.dig(:argument, :auto_vote) == 'true' &&
                         current_profile == current_user.profile))
  end

  def success_redirect_model(resource)
    return super unless action_name == 'create'
    resource.parent_model
  end
end
