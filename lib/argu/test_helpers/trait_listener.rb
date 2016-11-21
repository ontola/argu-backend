# frozen_string_literal: true
module Argu
  module TestHelpers
    class TraitListener
      include FactoryGirl::Syntax::Methods, Argu::TestHelpers::TestHelperMethods

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
          reset_publication(service.resource.publications.last)
          CreateArgument
            .new(service.resource.edge,
                 attributes: attributes_for(:argument),
                 options: service_options)
            .commit
        end
        3.times do
          service = CreateMotion
                      .new(@resource.edge,
                           attributes: attributes_for(:motion),
                           options: service_options)
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
        service = CreateQuestion
                  .new(@resource.edge,
                       attributes: attributes_for(:question),
                       options: service_options)
        service.commit
        reset_publication(service.resource.publications.last)
        service = CreateMotion
                    .new(service.resource.edge,
                         attributes: attributes_for(:motion),
                         options: service_options)
        service.commit
        reset_publication(service.resource.publications.last)
        create(:access_token, item: @resource)
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
          service = CreateArgument
                      .new(@resource.edge,
                           attributes: attributes_for(:argument).merge(pro: false),
                           options: service_options)
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
      end

      # Adds a follower to the edge of the resource
      # @see Follow#follow_type
      # @note Adds an extra {Notification} on associated resource creation
      def with_follower
        FactoryGirl.create(
          :follow,
          follower: FactoryGirl.create(:user, :follows_reactions_directly),
          followable: @resource.edge
        )
      end

      # Adds a news_follower to the edge of the resource
      # @see Follow#follow_type
      def with_news_follower
        FactoryGirl.create(
          :news_follow,
          follower: FactoryGirl.create(:user, :follows_news_directly),
          followable: @resource.edge
        )
      end

      # Adds 2 published and 2 trashed motions to the resource
      def with_motions
        2.times do
          service = CreateMotion
                      .new(
                        @resource.edge,
                        attributes: attributes_for(:motion),
                        options: service_options
                      )
          service.commit
          reset_publication(service.resource.publications.last)
          service = CreateMotion
                      .new(
                        @resource.edge,
                        attributes: attributes_for(:motion),
                        options: service_options
                      )
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
      end

      # Adds 2 pro, 2 neutral and 2 con votes to the resource
      def with_votes
        2.times do
          CreateVote
            .new(
              @resource.edge,
              attributes: vote_attrs(:pro),
              options: service_options
            )
            .commit
          CreateVote
            .new(
              @resource.edge,
              attributes: vote_attrs(:neutral),
              options: service_options
            )
            .commit
          CreateVote
            .new(
              @resource.edge,
              attributes: vote_attrs(:con),
              options: service_options
            )
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
          voteable_id: @resource.id,
          voteable_type: @resource.class.name,
          for: side
        }
      end
    end
  end
end
