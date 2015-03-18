class ForumsController < ApplicationController

  def index
    @forums = policy_scope(Forum).top_public_forums
    authorize Forum, :selector?

    render
  end

  def show
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :list?
    current_context @forum

    questions = policy_scope(@forum.questions.trashed(show_trashed?))

    question_answers = QuestionAnswer.arel_table
    motions = Motion.arel_table
    sql = motions.where(motions[:forum_id].eq(@forum.id).and(motions[:is_trashed].eq(show_trashed?))).join(question_answers, Arel::Nodes::OuterJoin)
              .on(question_answers[:motion_id].eq(motions[:id])).where(question_answers[:motion_id].eq(nil))
              .project(motions[Arel.star])
    motions_without_questions = Motion.find_by_sql(sql)

    @items = (questions + motions_without_questions).sort_by(&:updated_at).reverse if policy(@forum).show?

    render stream: false
  end

  def settings
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?
    current_context @forum
  end

  def statistics
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :statistics?
    current_context @forum

    @tags = []
    tag_ids = Tagging.where(forum_id: @forum.id).select(:tag_id).distinct.map(&:tag_id)
    tag_ids.each do |tag_id|
      taggings = Tagging.where(forum_id: @forum.id, tag_id: tag_id)
      @tags << {name: Tag.find(taggings.first.tag_id).name, count: taggings.length}
    end
    @tags = @tags.sort  { |x,y| y[:count] <=> x[:count] }
  end

  def update
    @forum = Forum.friendly.find params[:id]
    authorize @forum, :update?

    @forum.reload if process_cover_photo @forum, permit_params
    respond_to do |format|
      if @forum.update permit_params
        format.html { redirect_to settings_forum_path(@forum, tab: params[:tab]) }
      else
        format.html { render 'settings' }
      end
    end
  end

  def delete
  end

  def destroy
  end

  def selector
    @forums = Forum.top_public_forums
    authorize Forum, :selector?

    render layout: 'closed'
  end

  # POST /forums/memberships
  def memberships
    @forums = Forum.public_forums.where('id in (?)', params[:profile][:membership_ids].reject(&:blank?).map(&:to_i))
    @forums.each { |f| authorize f, :join? }

    @memberships = @forums.map { |f| Membership.find_or_initialize_by forum: f, profile: current_user.profile  }

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
      render 'forums/selector'
    end
  end

private
  def permit_params
    params.require(:forum).permit(*policy(@forum || Forum).permitted_attributes)
  end
end
