# frozen_string_literal: true
module SPI
  class AuthorizeController < SPI::SPIController
    include IRIHelper

    def show
      authorize resource, "#{params[:authorize_action]}?"
      head 200
    end

    private

    def resource
      return resource_from_iri(params[:resource_iri]) if params[:resource_iri].present?
      case params[:resource_type]
      when 'CurrentActor'
        profile = if (/[a-zA-Z]/i =~ params[:resource_id].to_s).present?
                    resource_from_iri(params[:resource_id]).profile
                  else
                    Profile.find(params[:resource_id])
                  end
        CurrentActor.new(user: current_user, actor: profile)
      else
        ApplicationRecord.descendants.detect { |m| m.to_s == params[:resource_type] }.find(params[:resource_id])
      end
    end
  end
end
