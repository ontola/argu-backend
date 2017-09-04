# frozen_string_literal: true

module Argu
  module TestHelpers
    class TraitListener
      include Argu::TestHelpers::TestHelperMethods
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
          create_redis_vote(Argument.last.edge, :pro)
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
        %i[pro neutral con].each do |side|
          create_normal_vote(@resource.default_vote_event.edge, side)
          create_hidden_vote(@resource.default_vote_event.edge, side)
          create_redis_vote(@resource.default_vote_event.edge, side)
          create_redis_postgres_vote(@resource.default_vote_event.edge, side)
        end
      end

      private

      def create_normal_vote(edge, side)
        CreateVote
          .new(
            edge,
            attributes: vote_attrs(side),
            options: service_options
          )
          .commit
      end

      def create_redis_vote(edge, side)
        CreateVote
          .new(edge, attributes: vote_attrs(side), options: guest_service_options)
          .commit
      end

      def create_redis_postgres_vote(edge, side)
        guest_vote_postgres =
          CreateVote
            .new(edge, attributes: vote_attrs(side), options: service_options)
        guest_vote_postgres.commit
        key = RedisResource::Key.new(
          path: guest_vote_postgres.resource.parent_edge.path,
          owner_type: 'Vote',
          user: guest_vote_postgres.resource.publisher,
          edge_id: guest_vote_postgres.resource.edge.id
        ).key
        Argu::Redis.set(key, guest_vote_postgres.resource.attributes.merge(persisted: true).to_json)
        guest_vote_postgres.resource.publisher.primary_email_record.update(confirmed_at: nil)
      end

      def create_hidden_vote(edge, side)
        CreateVote
          .new(
            edge,
            attributes: vote_attrs(side),
            options: service_options(are_votes_public: false)
          )
          .commit
      end

      def guest_service_options(id: 'guest_id')
        guest_user = GuestUser.new(id: id)
        {
          creator: guest_user.profile,
          publisher: guest_user
        }
      end

      def service_options(opts = {})
        user = create(:user, profile: build(:profile, opts))
        {
          creator: user.profile,
          publisher: user
        }
      end

      def vote_attrs(side)
        {
          voteable_id: @resource.id,
          voteable_type: @resource.class.name,
          explanation: 'explanation',
          for: side
        }
      end
    end
  end
end
