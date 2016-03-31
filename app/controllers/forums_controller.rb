# frozen_string_literal: true
class ForumsController < ApplicationController
  before_action :redirect_generic_shortnames, only: :show

  def index
    authorize Forum, :index?
    @user = User.find_via_shortname params[:id]
    authorize @user, :update?
    forums = Forum.arel_table
    @forums = Forum.where(forums[:page_id].in(@user.profile.pages.pluck(:id))
                            .or(forums[:id].in(@user.profile.managerships.pluck(:forum_id))))
    @_pundit_policy_scoped = true
  end

  def discover
    @forums = policy_scope(Forum).public_forums.page show_params[:page]
    authorize Forum, :selector?

    render
  end

  def show
    @forum = Forum.find_via_shortname params[:id]
    authorize @forum, :list?
    current_context @forum

    projects = policy_scope(@forum.projects)
    orphan_questions = policy_scope(@forum.questions.where(project_id: nil))
    orphan_motions = Motion.where(
      forum: @forum,
      question_id: nil,
      project_id: nil,
      is_trashed: show_trashed?)
    orphan_motions = policy_scope(orphan_motions)

    if policy(@forum).show?
      @items = Kaminari
               .paginate_array((projects + orphan_questions + orphan_motions)
                                   .sort_by(&:updated_at)
                                   .reverse)
               .page(show_params[:page])
               .per(30)
    end

    render
  end

  def settings
    @forum = Forum.find_via_shortname params[:id]
    authorize @forum, :update?
    current_context @forum

    prepend_view_path 'app/views/forums'

    render locals: {
      tab: tab,
      active: tab
    }
  end

  def statistics
    @forum = Forum.find_via_shortname params[:id]
    authorize @forum, :statistics?
    current_context @forum

    @tags = []
    tag_ids = Tagging.where(forum_id: @forum.id).select(:tag_id).distinct.map(&:tag_id)
    tag_ids.each do |tag_id|
      taggings = Tagging.where(forum_id: @forum.id, tag_id: tag_id)
      @tags << {name: Tag.find_by(id: taggings.first.tag_id).try(:name) || '[not found]', count: taggings.length}
    end
    @tags = @tags.sort { |x, y| y[:count] <=> x[:count] }
  end

  def update
    @forum = Forum.find_via_shortname params[:id]
    authorize @forum, :update?

    respond_to do |format|
      if @forum.update permit_params
        format.html { redirect_to settings_forum_path(@forum, tab: tab) }
      else
        format.html do
          render 'settings',
                 locals: {
                   tab: tab,
                   active: tab
                 }
        end
      end
    end
  end

  def selector
    @forums = Forum.top_public_forums
    authorize Forum, :selector?

    @forums = @forums.map! { |f| f.is_checked = f.profile_is_member?(current_user.profile); f }

    render layout: 'closed'
  end

  # POST /forums/memberships
  def memberships
    authorize Forum, :selector?
    @forums = Forum
              .public_forums
              .where('id in (?)',
                     (params[:profile][:membership_ids] || [])
                       .reject(&:blank?)
                       .map(&:to_i))
    @forums.each { |f| authorize f, :join? }

    @memberships = @forums.map { |f| Membership.find_or_initialize_by forum: f, profile: current_user.profile }

    success = false
    Membership.transaction do
      if @memberships.length >= 2 && @memberships.all?(&:save!)
        current_user.update_attribute :finished_intro, true
        success = true
      end
    end
    if success
      redirect_to root_path
    else
      flash[:error] = t('forums.selector.at_least_error')
      redirect_to selector_forums_path
    end
  end

  protected

  def correct_stale_record_version
    @forum.reload.attributes = permit_params.reject do |attrb, _value|
      attrb.to_sym == :lock_version
    end
  end

  def stale_record_recovery_action
    flash.now[:error] = 'Another user has made a change to that record since you accessed the edit form.'
    render 'settings', locals: {
      tab: tab,
      active: tab
    }
  end

  def forum_for(url_options)
    Forum.find_via_shortname_nil(url_options[:id])
  end

  private

  def permit_params
    pm = params.require(:forum).permit(*policy(@forum || Forum).permitted_attributes)
    merge_photo_params(pm, @resource.class)
    pm
  end

  def photo_params_nesting_path
    []
  end

  def redirect_generic_shortnames
    resource = Shortname.find_resource(params[:id]) || raise(ActiveRecord::RecordNotFound)
    redirect_to url_for(resource) unless resource.is_a?(Forum)
  end

  def show_params
    params.permit(:page)
  end

  def tab
    policy(@forum || Forum).verify_tab(params[:tab])
  end
end
