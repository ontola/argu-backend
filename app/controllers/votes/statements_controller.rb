class Votes::StatementsController < ApplicationController
  # POST /statements/:statement_id/vote/:for
  def create
    @statement = Statement.find(params[:statement_id])
    authorize! :vote, Statement
    if @statement && current_user && params[:for].in?(Avote::OPTIONS)
      @voted = Avote.where(voteable: @statement, voter: current_user).last.try(:for) unless current_user.blank?
      if @voted == permit_params[:for]
        respond_to do |format|
          format.json { render json: {notifications: [{type: 'warning', message: '_Stem ongewijzigd_'}]} }
        end
      else
        if Avote.create(for: permit_params[:for], voteable: @statement, voter: current_user)
          @voted = permit_params[:for]
          respond_to do |format|
            format.js # create.js.erb
            format.json { render json: {notifications: [{type: 'success', message: '_Gelukt_'}]} }
          end
        else
          render_error
        end
      end
    else
      render_error
    end
  end

  # DELETE /statements/:statement_id/vote
  def destroy
    @statement = Statement.find(params[:statement_id])
    authorize! :vote, Statement
    if @statement && current_user && Avote.create(for: :abstain, voteable: @statement, voter: current_user)
      respond_to do |format|
        format.json { render json: {notifications: [{type: 'success', message: '_Gelukt_'}]} }
      end
    else
      respond_to do |format|
        format.json { render json: {notifications: [{type: 'error', message: t('status.400')}] } }
      end
    end
  end

private
  def permit_params
    params.permit :for
  end

  def render_error
    respond_to do |format|
      format.json { render json: {notifications: [{type: 'error', message: t('status.400')}] } }
    end
  end
end