class Group < ActiveRecord::Base
  include IOrganisation
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  accepts_nested_attributes_for :group_memberships, :reject_if => :all_blank, :allow_destroy => true

end