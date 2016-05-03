class ShortnamesController < ApplicationController
  def new
    @forum = Forum.find_via_shortname params[:forum_id]
    @shortname = @forum.shortnames.new(owner_type: 'Question')
    authorize @shortname, :create?

    render_settings
  end

  def create
    @forum = Forum.find_via_shortname params[:forum_id]
    @shortname = @forum.shortnames.new(permit_params)

    authorize @shortname, :create?

    redirect_or_render(@shortname.save)
  rescue ActiveRecord::RecordNotUnique
    handle_record_not_unique
  end

  def edit
    @shortname = Shortname.find(params[:id])
    @forum = @shortname.forum

    authorize @shortname, :edit?

    render_settings(:edit)
  end

  def update
    @shortname = Shortname.find(params[:id])
    @forum = @shortname.forum

    authorize @shortname, :update?

    redirect_or_render(@shortname.update(permit_params), :edit)
  rescue ActiveRecord::RecordNotUnique
    handle_record_not_unique(:edit)
  end

  def destroy
    @shortname = Shortname.find(params[:id])
    @forum = @shortname.forum

    authorize @shortname, :destroy?

    flash[:error] = @shortname.errors.full_messages unless @shortname.destroy
    forum_settings_redirect
  end

  private

  def forum_settings_redirect
    redirect_to settings_forum_path(@forum, tab: 'shortnames')
  end

  def handle_record_not_unique(tab = :new)
    @shortname.errors.add :owner, t('activerecord.errors.record_not_unique')
    render_settings(tab)
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
