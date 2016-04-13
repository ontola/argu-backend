class FollowsController < ApplicationController
  before_action :check_user
  before_action :set_thing

  def create
    authorize @thing, :follow?

    if current_user.follow @thing
      respond_to do |format|
        format.html { redirect_to :back, notification: t('followed') }
        format.js { head 201 }
        format.json { head 201 }
      end
    else
      respond_to do |format|
        format.json { head 304 }
      end
    end
  end

  def destroy
    authorize @thing, :follow?

    resp = current_user.stop_following @thing
    if resp == nil || resp
      respond_to do |format|
        format.html { redirect_to :back, notification: t('unfollowed') }
        format.json { head 204 }
      end
    else
      respond_to do |format|
        format.json { head 400 }
      end
    end
  end

  private

  def check_user
    return if current_user.present?
    flash[:error] = t('devise.failure.unauthenticated')
    redirect_to :back
  end

  def set_thing
    klass = [Forum, Question, Motion, Argument, Comment, Project].detect { |c| params["#{c.name.underscore}_id"] }
    method = klass.respond_to?(:friendly) ? klass.friendly : klass
    @thing =
      if method.shortnameable?
        method.find_via_shortname(params["#{klass.name.underscore}_id"])
      else
        method.find(params["#{klass.name.underscore}_id"])
      end
    @forum = @thing.try :forum
  end
end
