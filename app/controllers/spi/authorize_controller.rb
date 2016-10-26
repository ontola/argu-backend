# frozen_string_literal: true
module SPI
  class AuthorizeController < SPI::SPIController
    def show
      model = ApplicationRecord.descendants.detect { |m| m.to_s == params[:resource_type] }
      authorize model.find(params[:resource_id]), "#{params[:authorize_action]}?"
      head 200
    end
  end
end
