class FollowsController < ApplicationController
  before_action :set_thing

  def create
    authorize @thing, :follow?

    if current_profile.follow @thing
      respond_to do |format|
        format.html { redirect_to :back, notification: '_notifications enabled_' }
        format.json { head 200 }
      end
    else
      respond_to do |format|
        format.json { head 400 }
      end
    end
  end

  def destroy
    authorize @thing, :follow?

    resp = current_profile.stop_following @thing
    if resp == nil || resp
      respond_to do |format|
        format.html { redirect_to :back, notification: '_notifications disabled_' }
        format.json { head 200 }
      end
    else
      respond_to do |format|
        format.json { head 400 }
      end
    end
  end

private
  def set_thing
    klass = [Forum, Question, Motion, Argument].detect { |c| params["#{c.name.underscore}_id"] }
    method = klass.respond_to?(:friendly) ? klass.friendly : klass
    @thing = method.find(params["#{klass.name.underscore}_id"])
  end
end
