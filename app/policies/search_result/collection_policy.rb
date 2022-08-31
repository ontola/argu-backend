# frozen_string_literal: true

class SearchResult
  class CollectionPolicy < ::CollectionPolicy
    def show?
      return page_policy.try(:administrator?) || page_policy.try(:staff?) unless public_resource?

      true
    end

    def public_resource?
      record.parent.try(:association_class) != User
    end

    private

    def page_policy
      @page_policy ||= Pundit.policy(context, ActsAsTenant.current_tenant)
    end
  end
end
