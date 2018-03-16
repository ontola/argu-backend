# frozen_string_literal: true

require 'argu/test_helpers/test_resources'

# Shared helper method across TestUnit and RSpec
module Argu
  module TestHelpers
    module TestHelperMethods
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods
        include TestResources::InstanceMethods
        SERVICE_MODELS = %i[argument blog_post comment forum group_membership motion
                            phase banner group project question vote decision grant vote_event vote_match].freeze

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts.dig(:forum) || try(:freetown)
        end

        def create(model_type, *args)
          attributes = HashWithIndifferentAccess.new
          attributes.merge!(args.pop) if args.last.is_a?(Hash)
          if SERVICE_MODELS.include?(model_type)
            create_with_service(model_type, args, attributes)
          else
            FactoryGirl.create(model_type, *args, attributes)
          end
        end

        def create_with_service(model_type, args, attributes)
          traits_with_args = attributes.delete(:traits_with_args) || {}
          klass = model_type.to_s.classify.constantize

          options = attributes.delete(:options) || {}
          options[:publisher] ||= attributes.delete(:publisher)
          options[:creator] ||= attributes.delete(:creator)

          attributes.merge!(attributes_for(model_type, attributes))
          attributes[:edge_attributes] ||= {} if model_type.to_s.classify.constantize.is_publishable?

          if klass.nested_attributes_options?
            klass.nested_attributes_options.each_key do |association|
              if attributes.include? association
                attributes["#{association}_attributes"] = attributes.delete(association).attributes
              end
            end
          end

          resource = create_resource(
            klass,
            attributes,
            options
          )

          args.each do |trait|
            TraitListener.new(resource).public_send(trait)
          end
          traits_with_args.each do |trait|
            TraitListener.new(resource).public_send(trait[0], trait[1])
          end

          if resource.respond_to?(:publications)
            reset_publication(resource.publications.last)
            resource.reload
          end

          resource
        end

        def create_moderator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          group = create(:group, parent: page.edge)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record.edge, group: group, grant_set: GrantSet.moderator)
          user
        end

        def create_participator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          group = create(:group, parent: page.edge)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record.edge, group: group, grant_set: GrantSet.participator)
          user
        end

        def create_initiator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          group = create(:group, parent: page.edge)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record.edge, group: group, grant_set: GrantSet.initiator)
          user
        end

        def create_administrator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.page
          create(:group_membership, parent: page.edge.groups.custom.first, member: user.profile)
          user
        end

        def create_forum_owner_pair(forum_opts = {}, manager_opts = {})
          user = create(:user, manager_opts)
          forum = create((forum_opts[:type] || :forum),
                         page: create(:page,
                                      owner: user.profile))
          [forum, user]
        end

        def create_follower(item, user = nil)
          user ||= create(:user)
          create(:follow, followable: item.edge, follower: user)
          user
        end

        def create_resource(klass, attributes = {}, options = {})
          if klass < Edgeable::Base || klass < NewsBoy || klass == VoteMatch
            options[:publisher] = create(:user, confirmed_at: Time.current) if options[:publisher].nil?
            options[:creator] = options[:publisher].profile if options[:creator].nil?
          end

          parent_edge = attributes.delete(:parent)

          service_class = "Create#{klass}".safe_constantize || CreateService
          service = service_class.new(parent_edge, attributes: attributes, options: options)
          service.commit
          raise service.resource.errors.full_messages.first unless service.resource.valid?
          service.resource.store_in_redis? ? service.resource : service.resource.reload
        end

        def destroy_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service_class = "Destroy#{resource.class}".safe_constantize || DestroyService
          service = service_class.new(resource, attributes: {}, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          nil
        end

        def open_file(filename)
          File.open("test/files/#{filename}")
        end

        def reset_publication(publication)
          return if publication.nil?
          publication.update(published_at: publication.published_at - 10.seconds) if publication.published_at.present?
          if publication.publish_time_lapsed?
            Sidekiq::Testing.inline! do
              publication.send(:reset)
            end
          else
            publication.send(:reset)
          end
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end

        def sign_in(resource = create(:user))
          id, role =
            case resource
            when :service
              [0, 'service']
            when :guest
              [SecureRandom.hex, 'guest']
            else
              [resource.id, 'user']
            end
          t = Doorkeeper::AccessToken.find_or_create_for(
            Doorkeeper::Application.argu,
            id,
            role,
            10.minutes,
            false
          )
          @request.headers['Authorization'] = "Bearer #{t.token}"
        end

        def trash_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service_class = "Trash#{resource.class}".safe_constantize || TrashService
          service = service_class.new(resource, attributes: {}, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end

        def update_resource(resource, attributes = {}, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          options = {}
          options[:publisher] = user
          options[:creator] = profile
          service_class = "Update#{resource.class}".safe_constantize || UpdateService
          service = service_class.new(resource, attributes: attributes, options: options)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end
      end

      module ClassMethods
        include TestResources::ClassMethods

        def define_automated_tests_objects
          define_common_objects(:freetown, :spectator, :user, :member, :non_member, :creator,
                                :manager, :owner, :staff, :page)
        end

        def define_common_objects(*let)
          define_freetown
          let(:spectator) { user } if mdig?(:spectator, let)
          let(:user) { create(:user) } if mdig?(:user, let)
          let(:initiator) { create_initiator(freetown) } if mdig?(:member, let)
          let(:non_member) { user } if mdig?(:non_member, let)
          let(:creator) { create_initiator(freetown) } if mdig?(:creator, let)
          let(:moderator) { create_moderator(freetown) } if mdig?(:manager, let)
          let(:administrator) { create_administrator(freetown) } if mdig?(:owner, let)
          let(:staff) { create(:user, :staff) } if mdig?(:staff, let)
          let(:page) { argu } if mdig?(:page, let)
        end

        def define_spec_objects
          let(:argu) { Page.find_via_shortname('argu') }
          let(:other_page_forum) { Forum.find_via_shortname('other_page_forum') }

          define_freetown_spec_objects
          define_hidden_spec_objects
        end

        def define_freetown_spec_objects
          let(:freetown) { Forum.find_via_shortname('freetown') }
          let(:linked_record) { LinkedRecord.first }
          let(:linked_record_argument) { LinkedRecord.first.arguments.first }
          let(:linked_record_vote) { LinkedRecord.first.votes.first }
          let(:linked_record_comment) { LinkedRecord.first.comment_threads.first }
          let(:project) { freetown.projects.first }
          let(:forum_motion) { freetown.motions.first }
          let(:question) { freetown.questions.first }
          let(:motion) { question.motions.first }
          let(:forum_motion) { freetown.motions.first }
          let(:decision) { motion.decisions.first }
          let(:vote_event) { motion.default_vote_event }
          let(:vote) { vote_event.votes.first }
          let(:argument) { motion.arguments.first }
          let(:argument_vote) { argument.votes.first }
          let(:comment) { argument.comment_threads.first }
          let(:nested_comment) { comment.children.first }
          let(:motion_comment) { motion.comment_threads.first }
          let(:blog_post) { question.blog_posts.first }
          let(:blog_post_comment) { blog_post.comment_threads.first }
          let(:motion_blog_post) { motion.blog_posts.first }
          let(:trashed_motion) { question.motions.trashed.first }
          let(:unpublished_motion) { question.motions.unpublished.first }
          let(:argument_unpublished_child) { unpublished_motion.arguments.first }
        end

        def define_hidden_spec_objects
          let(:holland) { Forum.find_via_shortname('holland') }
          let(:hidden_motion) { holland.edge.descendants.at_depth(4).where(owner_type: 'Motion').first.owner }
        end

        def define_model_spec_objects
          let(:described_method) do |example|
            desc =
              if example.example_group.description.starts_with?('#')
                example.example_group.parent.description
              elsif example.example_group.parent.description.starts_with?('#')
                example.example_group.parent.description
              elsif example.example_group.parent.parent.description.starts_with?('#')
                example.example_group.parent.parent.description
              end
            return nil unless desc.is_a?(String) && desc != '#initialize'
            desc[1..-1].to_sym
          end
        end

        # @param [Symbol] key The key to search for.
        # @param [Array] arr Array of options to search in.
        # @return [Boolean] Whether `key` is present in arr.
        def mdig?(key, arr)
          arr.include?(key)
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end
      end
    end
  end
end
