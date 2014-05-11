class CardsController < ApplicationController
  respond_to :html, :js

  def index
  end

  def show
    @card = Card.find_by_url params[:id]
    respond_to do |format|
      format.js { render json: {notifications: [ {type: :error, message: t('not_found_type', type: t('cards.type'))}]}, status: 404 if @card.blank? }
      format.html {}
    end
  end

  def new
    @card = Card.new
  end

  def create
  end

  def update
    @card = Card.find_by_url params[:id]

    if params[:card][:pages_index]
      new_indices = CGI::parse(params[:card][:pages_index])['card_pages_index']
      if new_indices.length == @card.card_pages.length
        ActiveRecord::Base.transaction do
          new_indices.each_with_index { |item, index|
            puts "page with index: #{item} and name #{@card.card_pages.find_by_page_index(item).url.to_s} gets index: #{index}"
            (card_page = @card.card_pages.find_by_page_index(item)).page_index = index
            card_page.save
          }
        end
      end
    end
    params[:card].delete :pages_index

    respond_to do |format|
      if @card.update_attributes!(params[:card])
        format.js { render json: {notifications: [{message: t('type_save_success', type: t('cards.type')), type: 'success' }]}.to_json }
      else
        format.js { render json: {notifications: [{message: @card.errors, type: 'error' }]}.to_json }
      end
    end
  end

  def delete
  end

  def destroy
  end
end