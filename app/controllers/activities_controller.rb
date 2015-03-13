class ActivitiesController < ApplicationController

  def index
    if params[:from_time].present?
      begin
        from_time = DateTime.parse(params[:from_time]).to_s
      rescue ArgumentError
        from_time = nil
      end
    end

    activities = Activity.arel_table
    @activities = policy_scope(Activity).since(from_time).order(activities[:created_at].desc).limit(10)
    Comment if Rails.env.development? # Fixes error in development where Comment isn't loaded yet

    respond_to do |format|
      if @activities.present?
        format.json { render json: @activities }
        format.html { render layout: 'layouts/activity', partial: 'layouts/activity', collection: @activities }
      else
        format.json { head 204 }
        format.html { head 204 }
      end
    end
  end

end