# frozen_string_literal: true

module DependentAssociations
  extend ActiveSupport::Concern

  private

  # Sets the dependent foreign relations to the Community profile
  def anonymize_dependencies
    with_dependent_associations do |association|
      association.model.try(:anonymize, association)
    end
  end

  # Destroys all records from the foreign relation
  def destroy_dependencies
    with_dependent_associations(&:destroy_all)
  end

  # Sets the dependent foreign relations to the Community profile
  def expropriate_dependencies
    with_dependent_associations do |association|
      association.model.try(:expropriate, association)
    end
  end

  def with_dependent_associations
    self.class.dependent_associations.each do |relation|
      ActsAsTenant.without_tenant do
        yield send(relation) if respond_to?(relation, true)
      end
    end
  end
end
