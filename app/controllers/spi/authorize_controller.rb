# frozen_string_literal: true
module SPI
  class AuthorizeController < SPI::SPIController
    def show
      authorize resource, "#{params[:authorize_action]}?"
      head 200
    end

    private

    def resource
      case params[:resource_type]
      when 'CurrentActor'
        CurrentActor.new(user: current_user, actor: Profile.find(params[:resource_id]))
      else
        ApplicationRecord.descendants.detect { |m| m.to_s == params[:resource_type] }.find(params[:resource_id])
      end
    end
  end
end
