class Organisation < ActiveRecord::Base
  include IOrganisation
  has_many :memberships
  has_many :users, through: :memberships
  accepts_nested_attributes_for :memberships, :reject_if => :all_blank, :allow_destroy => true

  enum scope: { scope_group: 0, scope_org: 1, scope_local: 2 }

  resourcify

  ######Roles#######
  def managers
    User.with_role :manager, self
  end

  ########Other########
  def self.scope_types
    HashWithIndifferentAccess[{scope_local: [], scope_org: [], scope_group: []}]
  end
end
