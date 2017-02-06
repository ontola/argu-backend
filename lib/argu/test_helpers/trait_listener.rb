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
        3.times do
          service = CreateQuestion
                    .new(@resource.edge,
                         attributes: attributes_for(:question),
                         options: service_options)
          service.commit
          reset_publication(service.resource.publications.last)
        end
        3.times do
          service = CreateQuestion
                      .new(@resource.edge,
                           attributes: attributes_for(:question),
                           options: service_options)
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
        service = CreateMotion
                    .new(Question.last.edge,
                         attributes: attributes_for(:motion),
                         options: service_options)
        service.commit
        reset_publication(service.resource.publications.last)
        create(:access_token, item: @resource)
        @resource.page.owner.profileable.follow @resource.edge
      end

      # Adds 3 pro (1 trashed) and 3 con (1 trashed) arguments to the resource
      def with_arguments
        [true, false].each do |pro|
          3.times do
            CreateArgument
              .new(@resource.edge,
                   attributes: attributes_for(:argument).merge(pro: pro),
                   options: service_options)
              .commit
          end
          TrashService.new(Argument.last, options: service_options).commit
        end
      end

      # Adds 3 attachments to the resource
      def with_attachments
        3.times do
          profile = create(:profile)
          @resource.attachments.create(
            creator: profile,
            forum: @resource.forum,
            publisher: profile.profileable,
            content: Rack::Test::UploadedFile.new(File.join(Rails.root, 'test', 'fixtures', 'profile_photo.png'))
          )
        end
      end

      # Adds 3 comments (1 trashed) to the resource
      def with_comments
        3.times do
          CreateComment
            .new(@resource.edge,
                 attributes: attributes_for(:comment),
                 options: service_options)
            .commit
        end
        TrashService.new(Comment.last, options: service_options).commit
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

      # Adds 2 public and 1 hidden votes to the resource for pro, neutral and con
      def with_votes
        %i(pro neutral con).each do |side|
          2.times do
            CreateVote
              .new(
                @resource.default_vote_event.edge,
                attributes: vote_attrs(side),
                options: service_options
              )
              .commit
          end
          CreateVote
            .new(
              @resource.default_vote_event.edge,
              attributes: vote_attrs(side),
              options: service_options(are_votes_public: false)
            )
            .commit
        end
      end

      private

      def service_options(opts = {})
        profile = create(:profile, opts)
        {
          creator: profile,
          publisher: profile.profileable
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
