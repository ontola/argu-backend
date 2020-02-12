# frozen_string_literal: true

module SPI
  class AuthorizeController < SPI::SPIController
    include IRIHelper

    def show
      head 200
    end

    private

    def authorize_action
      if resource!.try(:root)
        user_context.with_root(resource!.root) { authorize resource!, "#{params[:authorize_action]}?" }
      else
        authorize resource!, "#{params[:authorize_action]}?"
      end
    end

    def resource # rubocop:disable Metrics/AbcSize
      return resource_from_iri_param if resource_iri_param.present?

      case params[:resource_type]
      when 'CurrentActor'
        profile = if (/[a-zA-Z]/i =~ params[:resource_id].to_s).present?
                    resource_from_iri(params[:resource_id])&.profile
                  else
                    Profile.find_by(id: params[:resource_id])
                  end
        CurrentActor.new(user: current_user, actor: profile)
      else
        ApplicationRecord.descendants.detect { |m| m.to_s == params[:resource_type] }.find_by(id: params[:resource_id])
      end
    end

    def resource!
      resource || raise(ActiveRecord::RecordNotFound)
    end

    def resource_iri_param
      params[:resource_iri]
    end

    def resource_from_iri_param
      ActsAsTenant.with_tenant(TenantFinder.from_url(params[:resource_iri].to_s)) do
        resource_from_iri(path_to_url(resource_iri_param))
      end
    end

    def tree_root; end
  end
end
