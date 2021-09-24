# frozen_string_literal: true

module SPI
  class AuthorizeController < SPI::SPIController
    include NestedResourceHelper

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

    def current_actor_from_param
      CurrentActor.new(user: current_user, profile: profile_from_param)
    end

    def profile_from_param
      if (/[a-zA-Z]/i =~ resource_id_param).present?
        resource_from_iri(resource_id_param)&.profile
      else
        Profile.find_by(id: resource_id_param)
      end
    end

    def resource
      return resource_from_iri(resource_iri_param) if resource_iri_param.present?

      case params[:resource_type]
      when 'CurrentActor'
        current_actor_from_param
      else
        ApplicationRecord.descendants.detect { |m| m.to_s == params[:resource_type] }.find_by(id: params[:resource_id])
      end
    end

    def resource!
      resource || raise(ActiveRecord::RecordNotFound)
    end

    def resource_id_param
      params[:resource_id].to_s
    end

    def resource_iri_param
      params[:resource_iri].to_s
    end

    def resource_from_iri(iri)
      ActsAsTenant.with_tenant(TenantFinder.from_url(iri)) do
        LinkedRails.iri_mapper.resource_from_iri(path_to_url(iri), user_context)
      end
    end

    def tree_root; end
  end
end
