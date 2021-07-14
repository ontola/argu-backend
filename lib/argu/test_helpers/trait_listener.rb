# frozen_string_literal: true

module Argu
  module TestHelpers
    class TraitListener # rubocop:disable Metrics/ClassLength
      include Argu::TestHelpers::TestHelperMethods
      include FactoryBot::Syntax::Methods

      def initialize(resource)
        @resource = resource
      end

      def populated_forum # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        3.times do
          service = CreateEdge
                      .new(@resource,
                           attributes: attributes_for(:motion).merge(owner_type: 'Motion'),
                           options: service_options)
          service.on(:create_motion_failed) { raise service.resource.errors.full_messages.join('. ') }
          service.commit
          reset_publication(service.resource.publications.last)
          service = CreateProArgument.new(
            service.resource,
            attributes: attributes_for(:argument),
            options: service_options
          )
          service.commit
          reset_publication(service.resource.publications.last)
        end
        3.times do
          service = CreateEdge
                      .new(@resource,
                           attributes: attributes_for(:motion).merge(owner_type: 'Motion'),
                           options: service_options)
          service.on(:create_motion_failed) { raise service.resource.errors.full_messages.join('. ') }
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
        3.times do
          service = CreateEdge
                      .new(@resource,
                           attributes: attributes_for(:question).merge(owner_type: 'Question'),
                           options: service_options)
          service.on(:create_question_failed) { raise service.resource.errors.full_messages.join('. ') }
          service.commit
          reset_publication(service.resource.publications.last)
        end
        3.times do
          service = CreateEdge
                      .new(@resource,
                           attributes: attributes_for(:question).merge(owner_type: 'Question'),
                           options: service_options)
          service.on(:create_question_failed) { raise service.resource.errors.full_messages.join('. ') }
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
        service = CreateEdge
                    .new(Question.last,
                         attributes: attributes_for(:motion).merge(owner_type: 'Motion'),
                         options: service_options)
        service.on(:create_motion_failed) { raise service.resource.errors.full_messages.join('. ') }
        service.commit
        reset_publication(service.resource.publications.last)
        @resource.root.publisher.follow @resource
      end

      # Adds 3 pro (1 trashed) and 3 con (1 trashed) arguments to the resource
      def with_arguments # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        [true, false].each do |pro|
          3.times do
            service = CreateProArgument
                        .new(@resource,
                             attributes: attributes_for(:argument).merge(pro: pro),
                             options: service_options)
            service.commit
            reset_publication(service.resource.publications.last)
          end
          create_redis_vote(Argument.last, :yes)
          TrashService.new(Argument.last, options: service_options).commit
        end
      end

      # Adds 3 attachments to the resource
      def with_attachments # rubocop:disable Metrics/MethodLength
        3.times do
          profile = create(:profile)
          @resource.attachments.create(
            creator: profile,
            forum: @resource.ancestor(:forum),
            publisher: profile.profileable,
            content: Rack::Test::UploadedFile.new(
              Rails.root.join('test/fixtures/profile_photo.png')
            )
          )
        end
      end

      # Adds 3 comments (1 trashed) to the resource
      def with_comments
        3.times do
          service = CreateEdge
                      .new(@resource,
                           attributes: attributes_for(:comment).merge(owner_type: 'Comment'),
                           options: service_options)
          service.commit
          reset_publication(service.resource.publications.last)
        end
        TrashService.new(Comment.last, options: service_options).commit
      end

      # Adds a follower to the edge of the resource
      # @see Follow#follow_type
      # @note Adds an extra {Notification} on associated resource creation
      def with_follower
        FactoryBot.create(
          :follow,
          follower: FactoryBot.create(:user, :follows_reactions_directly),
          followable: @resource
        )
      end

      # Adds a news_follower to the edge of the resource
      # @see Follow#follow_type
      def with_news_follower
        FactoryBot.create(
          :news_follow,
          follower: FactoryBot.create(:user, :follows_news_directly),
          followable: @resource
        )
      end

      # Adds 2 published and 2 trashed motions to the resource
      def with_motions # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        2.times do
          service = CreateEdge
                      .new(
                        @resource,
                        attributes: attributes_for(:motion).merge(owner_type: 'Motion'),
                        options: service_options
                      )
          service.commit
          reset_publication(service.resource.publications.last)
          service = CreateEdge
                      .new(
                        @resource,
                        attributes: attributes_for(:motion).merge(owner_type: 'Motion'),
                        options: service_options
                      )
          service.commit
          TrashService.new(service.resource, options: service_options).commit
        end
      end

      # Adds 2 public and 1 hidden votes to the resource for pro, neutral and con
      def with_votes
        %i[yes other no].each do |side|
          create_normal_vote(@resource.default_vote_event, side)
          create_hidden_vote(@resource.default_vote_event, side)
          create_redis_vote(@resource.default_vote_event, side)
        end
      end

      private

      def create_normal_vote(edge, side)
        service =
          CreateVote.new(
            edge,
            attributes: vote_attrs(side),
            options: service_options
          )
        service.commit
        create_comment_for_vote(service.resource)
      end

      def create_comment_for_vote(vote)
        service = CreateEdge.new(
          vote.voteable,
          attributes: {content: 'opinion', owner_type: 'Comment'},
          options: {user_context: UserContext.new(profile: vote.creator, user: vote.publisher)}
        )
        service.commit
        reset_publication(service.resource.publications.last)
      end

      def create_redis_vote(edge, side)
        service = CreateVote.new(edge, attributes: vote_attrs(side), options: guest_service_options)
        service.commit
      end

      def create_hidden_vote(edge, side)
        service = CreateVote.new(
          edge,
          attributes: vote_attrs(side),
          options: service_options(show_feed: false)
        )
        service.commit
        create_comment_for_vote(service.resource)
      end

      def guest_service_options(session_id: 'guest_id')
        guest_user = GuestUser.new(session_id: session_id)
        {
          user_context: UserContext.new(profile: guest_user.profile, user: guest_user)
        }
      end

      def service_options(opts = {})
        user = create(:user, opts)
        {
          user_context: UserContext.new(user: user, profile: user.profile)
        }
      end

      def vote_attrs(side)
        {
          option: side
        }
      end
    end
  end
end
