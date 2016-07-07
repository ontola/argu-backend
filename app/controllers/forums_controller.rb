# frozen_string_literal: true
class ForumsController < AuthorizedController
  prepend_before_action :redirect_generic_shortnames, only: :show
  skip_before_action :authorize_action, only: %i(show index)
  skip_before_action :check_if_registered, only: %i(discover)
  skip_before_action :check_if_member, only: %i(discover index)

  def index
    authorize resource_by_id, :update?
    forums = Forum.arel_table
    @forums = Forum.where(forums[:page_id].in(@user.profile.pages.pluck(:id))
                            .or(forums[:id].in(@user.profile.managerships.pluck(:forum_id))))
    @_pundit_policy_scoped = true
  end

  def discover
    @forums = policy_scope(Forum)
                .public_forums
                .includes(:default_cover_photo, :default_profile_photo, :shortname, :access_tokens)
                .page show_params[:page]
    render
  end

  def show
    if policy(resource_by_id).show?
      projects = policy_scope(resource_by_id
                                .projects
                                .includes(:edge, :default_cover_photo)
                                .published
                                .trashed(show_trashed?))
      questions = policy_scope(resource_by_id
                                 .questions
                                 .where(project_id: nil)
                                 .includes(:edge, :project, :default_cover_photo)
                                 .published
                                 .trashed(show_trashed?))
      motions = policy_scope(resource_by_id
                               .motions
                               .where(project_id: nil, question_id: nil)
                               .includes(:edge, :question, :project, :default_cover_photo, :votes)
                               .published
                               .trashed(show_trashed?))

      @items = Kaminari
               .paginate_array((projects + questions + motions)
                                   .sort_by(&:updated_at)
                                   .reverse)
               .page(show_params[:page])
               .per(30)
    end
  end

  def settings
    prepend_view_path 'app/views/forums'

    render locals: {
      tab: tab,
      active: tab
    }
  end

  def statistics
    render :statistics,
           locals: {
             content_counts: content_count(resource_by_id),
             city_counts: city_count(resource_by_id),
             tag_counts: tag_count(resource_by_id)
           }
  end

  def update
    update_service.on(:update_forum_successful) do |forum|
      redirect_to settings_forum_path(forum, tab: tab), notice: t('type_save_success', type: t('forums.type'))
    end
    update_service.on(:update_forum_failed) do
      render 'settings',
             locals: {
               tab: tab,
               active: tab
             }
    end
    update_service.commit
  end

  def selector
    @forums = Forum.top_public_forums

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

  def forum_for(url_options)
    Forum.find_via_shortname_nil(url_options[:id])
  end

  protected

  def correct_stale_record_version
    resource_by_id.reload.attributes = permit_params.reject do |attrb, _value|
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

  private

  def authorize_show
    authorize resource_by_id, :list?
  end

  def authorize_action
    authorize authenticated_resource! || Forum, "#{params[:action].chomp('!')}?"
  end

  def city_count(forum)
    cities = Hash.new(0)
    User
      .where(id: forum.members.where(profileable_type: 'User').pluck(:profileable_id))
      .includes(home_placement: :place)
      .map { |u| u.home_placement&.place&.address.try(:[],'city') }
      .each { |v| cities.store(v, cities[v] + 1) }
    cities.sort { |x,y| y[1] <=> x[1] }
  end

  def content_count(forum)
    forum
      .edge
      .descendants
      .where(owner_type: %w(Argument Vote Project Question Motion Comment))
      .group(:owner_type)
      .count
      .sort { |x,y| y[1] <=> x[1] }
  end

  def permit_params
    pm = params.require(:forum).permit(*policy(resource_by_id || Forum).permitted_attributes)
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

  def resource_by_id
    return if params[:id].nil?
    if action_name == 'index'
      @user ||= User.find_via_shortname params[:id]
    else
      @forum ||= Forum.find_via_shortname params[:id]
    end
  end

  def show_params
    params.permit(:page)
  end

  def tab
    policy(resource_by_id || Forum).verify_tab(params[:tab] || params[:forum].try(:[], :tab))
  end

  def tag_count(forum)
    tags = []
    tag_ids = Tagging.where(forum_id: forum.id).select(:tag_id).distinct.map(&:tag_id)
    tag_ids.each do |tag_id|
      taggings = Tagging.where(forum_id: forum.id, tag_id: tag_id)
      tags << {name: Tag.find_by(id: taggings.first.tag_id).try(:name) || '[not found]', count: taggings.length}
    end
    tags.sort { |x, y| y[:count] <=> x[:count] }
  end
end
