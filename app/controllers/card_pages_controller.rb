class CardPagesController < ApplicationController
  respond_to :html, :js

  def index

  end

  def show
    @card = Card.find_by_url(params[:card_id])
    @card_page = @card.card_pages.find_by_id(params[:id])
    respond_to do |format|
      if @card_page.blank?
        format.html { render "/cards/show" }
        format.js { head 404 }
      else
        format.html { render "/cards/show" }
        format.js {}
      end
    end
  end

  def new
    @card_page = Card.find_by_url(params[:card_id]).card_pages.new
    head 404 if @card_page.blank?
  end

  def create
    @card_page = Card.find_by_url(params[:card_id]).card_pages.new

    respond_to do |format|
      if @card_page.update_attributes params[:card_page]
        format.html { redirect_to @card_page.card }
        format.js { render json: {card_page: @card_page}.to_json }
      else
        format.html {}
        format.js { render json: {notifications: [{message: '_vreselijke fout_', type: 'error'}]}.to_json }
      end
    end
  end

  def delete

  end

  def destroy

  end
end