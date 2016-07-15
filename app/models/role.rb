# frozen_string_literal: true
class Role < ActiveRecord::Base
  has_and_belongs_to_many :profiles, join_table: 'users_roles'
  belongs_to :resource, polymorphic: true

  scopify

  validates :name, presence: true
end
