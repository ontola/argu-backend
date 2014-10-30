class Organisation < ActiveRecord::Base
  include IOrganisation
  has_many :memberships, dependent: :destroy
  has_many :profiles, through: :memberships
  has_many :questions, inverse_of: :organisation
  accepts_nested_attributes_for :memberships, :allow_destroy => true

  validate :manager_present?

  enum scope: { scope_group: 0, scope_org: 1, scope_local: 2 }

  resourcify

  def manager_present?
    unless memberships.collect { |m| m.role == 'manager' }
      errors.add :base, "_manager not present_"
    end
  end

  ######Roles#######
  def managers
    Profile.with_role :manager, self
  end

  ########Other########
  def self.scope_types
    HashWithIndifferentAccess[{scope_local: [], scope_org: []}]
  end
end
