class ShortnamesController < ApplicationController
  include NestedResourceHelper
  before_action :initialize_resource, :filter_lesser_roles

  def new
    @shortname = @forum.shortnames.new(owner_type: 'Question')
    authorize @shortname, :create?

    render_settings
  end

  def create
    @shortname = @forum.shortnames.new(permit_params)

    authorize @shortname, :create?

    redirect_or_render(@shortname.save)
  rescue ActiveRecord::RecordNotUnique
    handle_record_not_unique
  end

  def edit
    authorize @shortname, :edit?

    render_settings(:edit)
  end

  def update
    authorize @shortname, :update?

    redirect_or_render(@shortname.update(permit_params), :edit)
  rescue ActiveRecord::RecordNotUnique
    handle_record_not_unique(:edit)
  end

  def destroy
    authorize @shortname, :destroy?

    flash[:error] = @shortname.errors.full_messages unless @shortname.destroy
    forum_settings_redirect
  end

  private

  def filter_lesser_roles
    raise Argu::NotAuthorizedError.new(query: "#{params[:action]}?") unless policy(@forum).is_manager_up?
  end

  def forum_settings_redirect
    redirect_to settings_forum_path(@forum, tab: 'shortnames')
  end

  def handle_record_not_unique(tab = :new)
    @shortname.errors.add :owner, t('activerecord.errors.record_not_unique')
    render_settings(tab)
  end

  def initialize_resource
    if %w(new create).include?(params[:action])
      @forum = get_parent_resource
    else
      @shortname = Shortname.find(params[:id])
      @forum = @shortname.forum
    end
  end

  def redirect_or_render(result, tab = :new)
    if result
      forum_settings_redirect
    else
      render_settings(tab)
    end
  end

  def render_settings(tab = :new)
    render 'forums/settings',
           locals: {
             tab: "shortnames/#{tab}",
             active: 'shortnames'
           }
  end

  def permit_params
    p = params.require(:shortname).permit(*policy(@shortname || Shortname).permitted_attributes)
    p['owner_type'] = nil unless %w(Project Question Motion Argument Comment).include?(p['owner_type'])
    p
  end
end
