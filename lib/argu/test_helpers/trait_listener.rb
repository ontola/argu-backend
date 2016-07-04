# frozen_string_literal: true

module Argu
  module TestHelpers
    class TraitListener
      include FactoryGirl::Syntax::Methods

      def initialize(resource)
        @resource = resource
      end

      def populated_forum
        3.times do
          service = CreateMotion
                      .new(@resource.edge,
                           attributes: attributes_for(:motion),
                           options: service_options)
          service.commit
          CreateArgument
            .new(service.resource.edge,
                 attributes: attributes_for(:argument),
                 options: service_options)
            .commit
        end
        3.times do
          CreateMotion
            .new(@resource.edge,
                 attributes: attributes_for(:motion, is_trashed: true),
                 options: service_options)
            .commit
        end
        service = CreateQuestion
                    .new(@resource.edge,
                         attributes: attributes_for(:question),
                         options: service_options)
        service.commit
        CreateMotion
          .new(service.resource.edge,
               attributes: attributes_for(:motion),
               options: service_options)
          .commit
        create(:access_token, item: @resource)
        cap = Setting.get('user_cap').try(:to_i)
        Setting.set('user_cap', -1) unless cap.present?
        @resource.page.owner.profileable.follow @resource.edge
      end

      # Adds 3 pro and 3 con arguments to the resource
      def with_arguments
        3.times do
          CreateArgument
            .new(@resource.edge,
                 attributes: attributes_for(:argument),
                 options: service_options)
            .commit
          CreateArgument
            .new(@resource.edge,
                 attributes: attributes_for(:argument)
                   .merge(
                     pro: false,
                     is_trashed: true
                   ),
                 options: service_options)
            .commit
        end
      end

      # Adds a follower to the edge of the resource
      # See {Follow}
      # @note Adds an extra {Notification} on associated resource creation
      def with_follower
        FactoryGirl.create(
          :follow,
          follower: FactoryGirl.create(:user, :follows_reactions_directly),
          followable: @resource.edge)
      end

      # Adds a discussion group with 2 GroupResponses and a visible and a hidden group without reponses
      # to the forum of the resource
      def with_group_responses
        service = CreateGroup.new(@resource.forum.edge, attributes: {visibility: :discussion}, options: service_options)
        service.commit
        group = service.resource
        2.times do
          CreateGroupResponse
            .new(@resource.edge,
                 attributes: {group: group},
                 options: service_options)
            .commit
        end
        FactoryGirl.create(
          :group,
          visibility: :hidden,
          forum: @resource.forum)
        FactoryGirl.create(
          :group,
          visibility: :visible,
          forum: @resource.forum)
      end

      # Adds 2 published and 2 trashed motions to the resource
      def with_motions
        2.times do
          CreateMotion
            .new(
              @resource.edge,
              attributes: attributes_for(:motion),
              options: service_options)
            .commit
          CreateMotion
            .new(
              @resource.edge,
              attributes: attributes_for(:motion)
                .merge(is_trashed: true),
              options: service_options)
            .commit
        end
      end

      # Adds 2 pro, 2 neutral and 2 con votes to the resource
      def with_votes
        2.times do
          CreateVote
            .new(
              @resource.edge,
              attributes: vote_attrs(:pro),
              options: service_options)
            .commit
          CreateVote
            .new(
              @resource.edge,
              attributes: vote_attrs(:neutral),
              options: service_options)
            .commit
          CreateVote
            .new(
              @resource.edge,
              attributes: vote_attrs(:con),
              options: service_options)
            .commit
        end
      end

      private

      def service_options
        user = create(:user)
        {
          creator: user.profile,
          publisher: user
        }
      end

      def vote_attrs(side)
        {
          voteable: @resource,
          for: side
        }
      end
    end
  end
end
