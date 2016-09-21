# frozen_string_literal: true
module Groupable
  extend ActiveSupport::Concern

  included do
    after_create :create_default_group

    def create_default_group
      case self
      when Forum
        group = Group.new(
          name: "#{name} members",
          name_singular: "#{name} member",
          page: page,
          deletable: false
        )
        group.grants << Grant.new(role: Grant.roles[:member], edge: edge)
        group.edge = Edge.new(user: publisher, parent: edge)
        group.save!
      when Page
        group = Group.new(
          name: 'Managers',
          name_singular: 'Manager',
          page: self,
          deletable: false
        )
        group.grants << Grant.new(role: Grant.roles[:manager], edge: edge)
        group.edge = Edge.new(user: publisher, parent: edge)
        group.save!
      end
    end

    def members_group
      @members_group ||= grants.member.includes(group: :grants).first.group
    end
  end
end
