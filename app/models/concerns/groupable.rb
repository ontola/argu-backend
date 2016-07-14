module Groupable
  extend ActiveSupport::Concern

  included do
    after_create :create_default_groups

    def create_default_groups
      group = Group.new(
        name: is_a?(Forum) ? "#{name} members" : 'Members',
        name_singular: is_a?(Forum) ? "#{name} member" : 'Member',
        page: is_a?(Forum) ? page : self,
        deletable: false)
      group.grants << Grant.new(role: Grant.roles[:member], edge: edge)
      group.edge = Edge.new(user: publisher, parent: edge)
      group.save!

      group = Group.new(
        name: is_a?(Forum) ? "#{name} managers" : 'Managers',
        name_singular: is_a?(Forum) ? "#{name} manager" : 'Manager',
        page: is_a?(Forum) ? page : self,
        deletable: false)
      group.grants << Grant.new(role: Grant.roles[:manager], edge: edge)
      group.edge = Edge.new(user: publisher, parent: edge)
      group.save!
    end

    def managers_group
      @managers_group ||= grants.manager.includes(group: :grants).first.group
    end

    def members_group
      @members_group ||= grants.member.includes(group: :grants).first.group
    end
  end
end
