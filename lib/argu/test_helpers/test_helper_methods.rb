# frozen_string_literal: true

# Shared helper method across TestUnit and RSpec
module Argu
  module TestHelpers
    module TestHelperMethods
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods # rubocop:disable Metrics/ModuleLength
        include JWTHelper
        include TestResources::InstanceMethods
        SERVICE_MODELS = %i[
          argument pro_argument con_argument blog_post comment forum group_membership motion export
          group question vote decision grant vote_event page topic risk intervention intervention_type
          measure measure_type employment
        ].freeze

        def argu_headers(accept: :nq, bearer: nil, host: nil)
          headers = {}
          headers['Accept'] = accept.is_a?(Symbol) ? Mime::Type.lookup_by_extension(accept).to_s : accept
          headers['Authorization'] = "Bearer #{bearer}" if bearer
          headers['HTTP_HOST'] = host if host
          headers
        end

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts.dig(:forum) || try(:freetown)
        end

        def decoded_token_from_response
          decode_token(client_token_from_response)
        end

        def doorkeeper_token_for(resource)
          id, role =
            case resource
            when :service
              [User::SERVICE_ID, 'service']
            when :guest_user
              [SecureRandom.hex, 'guest']
            when GuestUser
              [resource.id, 'guest']
            else
              [resource.id, 'user']
            end
          Doorkeeper::AccessToken.create!(
            application: Doorkeeper::Application.argu,
            resource_owner_id: id,
            scopes: role,
            expires_in: 10.minutes,
            use_refresh_token: true
          )
        end

        def client_token_from_response
          response.headers['New-Authorization'] || assigns(:doorkeeper_token).token
        rescue NoMethodError
          nil
        end

        def create(model_type, *args)
          attributes = HashWithIndifferentAccess.new
          attributes.merge!(args.pop) if args.last.is_a?(Hash)
          if SERVICE_MODELS.include?(model_type)
            create_with_service(model_type, args, attributes)
          else
            FactoryBot.create(model_type, *args, attributes)
          end
        end

        def create_with_service(model_type, args, attributes) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          traits_with_args = attributes.delete(:traits_with_args) || {}
          klass = model_type.to_s.classify.constantize

          options = attributes.delete(:options) || {}
          options[:publisher] ||= attributes.delete(:publisher)
          options[:creator] ||= attributes.delete(:creator)

          attributes.merge!(attributes_for(model_type, attributes))

          if klass.nested_attributes_options?
            klass.nested_attributes_options.each_key do |association|
              if attributes.include? association
                attributes["#{association}_attributes"] = attributes.delete(association).attributes
              end
            end
          end

          ActsAsTenant.with_tenant(attributes[:parent]&.root) do
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
        end

        def create_guest_user(id: nil)
          GuestUser.new(id: id || @request&.session&.id || SecureRandom.hex)
        end

        def create_moderator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.root
          group = create(:group, parent: page)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record, group: group, grant_set: GrantSet.moderator)
          user
        end

        def create_spectator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.root
          group = create(:group, parent: page)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record, group: group, grant_set: GrantSet.spectator)
          user
        end

        def create_participator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.root
          group = create(:group, parent: page)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record, group: group, grant_set: GrantSet.participator)
          user
        end

        def create_initiator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.root
          group = create(:group, parent: page)
          create(:group_membership,
                 parent: group,
                 shortname: user.url)
          create(:grant, edge: record, group: group, grant_set: GrantSet.initiator)
          user
        end

        def create_administrator(record, user = nil)
          user ||= create(:user)
          page = record.is_a?(Page) ? record : record.root
          create(:group_membership, parent: page.groups.find_by(name: 'Admins'), member: user.profile)
          user
        end

        def create_follower(item, user = nil)
          user ||= create(:user)
          create(:follow, followable: item, follower: user)
          user
        end

        # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        def create_resource(klass, attributes = {}, options = {})
          parent_edge = attributes.delete(:parent)
          ActsAsTenant.with_tenant(parent_edge&.root || ActsAsTenant.current_tenant) do
            if klass < Edge
              options[:publisher] = create(:user, confirmed_at: Time.current) if options[:publisher].nil?
              options[:creator] = options[:publisher].profile if options[:creator].nil?
              attributes[:owner_type] = klass.to_s
            end

            service_class = "Create#{klass}".safe_constantize || service_class_fallback(klass)
            service = service_class.new(parent_edge, attributes: attributes, options: options)
            service.commit
            raise service.resource.errors.full_messages.first unless service.resource.valid?

            service.resource.store_in_redis? ? service.resource : service.resource.reload
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

        def destroy_resource(resource, user = nil, profile = nil)
          ActsAsTenant.with_tenant(resource&.root || ActsAsTenant.current_tenant) do
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
        end

        def open_file(filename)
          File.open("test/files/#{filename}")
        end

        def reset_tenant
          ActsAsTenant.current_tenant = nil
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

        def service_class_fallback(klass)
          klass <= Edge ? CreateEdge : CreateService
        end

        def stats_opt(category, action)
          {category: category, action: action}
        end

        def sign_in(resource = create(:user))
          @request.headers['Authorization'] = "Bearer #{doorkeeper_token_for(resource).token}"
        end

        def tenant_from(resource)
          ActsAsTenant.current_tenant = resource.root
        end

        def trash_resource(resource, user = nil, profile = nil) # rubocop:disable Metrics/AbcSize
          ActsAsTenant.with_tenant(resource&.root || ActsAsTenant.current_tenant) do
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
        end

        def update_resource(resource, attributes = {}, user = nil, profile = nil) # rubocop:disable Metrics/AbcSize
          ActsAsTenant.with_tenant(resource&.root || ActsAsTenant.current_tenant) do
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

        def worker_count_string(worker, args = nil)
          str = "Sidekiq::Worker.jobs.select { |job| job['class'] == '#{worker}'"
          str += " && job['args'] == #{args}" if args
          str += '}.count'
          str
        end
      end

      module ClassMethods
        include TestResources::ClassMethods

        def define_automated_tests_objects
          define_common_objects(:freetown, :spectator, :user, :member, :non_member, :creator,
                                :manager, :owner, :staff, :page)
        end

        # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
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
        # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

        def define_spec_objects
          let(:argu) { Page.argu }
          let(:other_page) { Page.find_via_shortname('other_page') }
          let(:other_page_forum) { Forum.find_via_shortname('other_page_forum') }
          let(:other_forum) { Forum.find_via_shortname('holland') }
          define_freetown_spec_objects
          define_hidden_spec_objects
        end

        def define_freetown_spec_objects # rubocop:disable Metrics/AbcSize
          let(:freetown) { Forum.find_via_shortname('freetown') }
          let(:group) { Group.find_by(name: 'custom') }
          let(:group_membership) { group.group_memberships.first }
          let(:linked_record) { LinkedRecord.first }
          let(:linked_record_argument) { LinkedRecord.first.arguments.first }
          let(:linked_record_vote) { LinkedRecord.first.default_vote_event.votes.first }
          let(:linked_record_comment) { LinkedRecord.first.comments.first }
          let(:forum_motion) { freetown.motions.first }
          let(:question) { freetown.questions.first }
          let(:motion) { question.motions.first }
          let(:forum_topic) { freetown.topics.first }
          let(:decision) { motion.decisions.first }
          let(:vote_event) { motion.default_vote_event }
          let(:vote) { vote_event.votes.first }
          let(:argument) { motion.arguments.first }
          let(:argument_vote) { argument.votes.first }
          let(:comment) { argument.comments.first }
          let(:nested_comment) { comment.comments.first }
          let(:motion_comment) { motion.comments.first }
          let(:blog_post) { question.blog_posts.first }
          let(:blog_post_comment) { blog_post.comments.first }
          let(:motion_blog_post) { motion.blog_posts.first }
          let(:trashed_question) { freetown.questions.trashed.first }
          let(:unpublished_question) { freetown.questions.unpublished.first }
          let(:argument_unpublished_child) { unpublished_question.motions.first.arguments.first }
          let(:forum_export) { freetown.exports.first }
          let(:motion_export) { motion.exports.first }
        end

        def define_hidden_spec_objects
          let(:holland) { Forum.find_via_shortname('holland') }
          let(:hidden_motion) { holland.descendants.at_depth(4).where(owner_type: 'Motion').first }
        end

        def define_model_spec_objects # rubocop:disable Metrics/AbcSize
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
