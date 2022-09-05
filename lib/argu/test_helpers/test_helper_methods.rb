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
          argument banner blog_post budget_shop comment con_argument coupon_batch export forum
          group group_membership grant motion offer order order_detail
          page poll pro_argument question swipe_tool submission survey term topic vocabulary vote vote_event
        ].freeze

        def argu_headers(accept: :nq, bearer: nil, host: nil, referrer: nil, content_type: nil)
          headers = {}
          headers['Accept'] = accept.is_a?(Symbol) ? Mime::Type.lookup_by_extension(accept).to_s : accept
          headers['Content-Type'] = Mime::Type.lookup_by_extension(content_type).to_s if content_type
          headers['Authorization'] = "Bearer #{bearer}" if bearer
          headers['HTTP_HOST'] = host if host
          headers['Request-Referrer'] = referrer.to_s if referrer
          headers
        end

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts[:forum] || try(:freetown)
        end

        def decoded_token_from_response
          decode_token(client_token_from_response)
        end

        def doorkeeper_token_for(resource, expires_in: 10.minutes) # rubocop:disable Metrics/MethodLength
          owner, role =
            case resource
            when :service
              [User.service, 'service']
            when :guest_user
              [User.guest, 'guest']
            when resource.guest?
              [resource, 'guest']
            else
              [resource, 'user']
            end
          resource_owner = UserContext.new(user: owner, profile: owner.profile, session_id: owner.session_id)
          Doorkeeper::AccessToken.create!(
            application: frontend_application,
            resource_owner: resource_owner,
            scopes: role,
            expires_in: expires_in,
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

        def create_with_name(model_type, shortname, attributes)
          attributes.merge!(
            title: "#{shortname}-title",
            content: "#{shortname}-text"
          )

          create_with_shortname(model_type, shortname, attributes)
        end

        def create_with_shortname(model_type, shortname, attributes)
          resource = create(model_type, attributes)
          Shortname.create!(shortname: shortname, owner: resource, root: resource.root)

          resource
        end

        def create_with_service(model_type, args, attributes) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          traits_with_args = attributes.delete(:traits_with_args) || {}
          klass = model_type.to_s.classify.constantize

          options = attributes.delete(:options) || {}
          options[:publisher] ||= attributes.delete(:publisher)
          options[:creator] ||= attributes.delete(:creator)

          attributes = attributes_for(model_type, attributes).merge(attributes).with_indifferent_access

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
              **options
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

        def create_guest_user(session_id: SecureRandom.hex)
          User.guest(session_id)
        end

        def create_group_membership(record, user, group = nil)
          page = record.is_a?(Page) ? record : record.root
          group ||= create(:group, parent: page)
          user ||= create(:user)

          page.join_user(user)

          create(:group_membership,
                 parent: group,
                 member: user.profile)
        end

        def create_moderator(record, user = nil)
          membership = create_group_membership(record, user)
          create(:grant, edge: record, group: membership.group, grant_set: GrantSet.moderator)
          membership.user
        end

        def create_spectator(record, user = nil)
          membership = create_group_membership(record, user)
          create(:grant, edge: record, group: membership.group, grant_set: GrantSet.spectator)
          membership.user
        end

        def create_participator(record, user = nil)
          membership = create_group_membership(record, user)
          create(:grant, edge: record, group: membership.group, grant_set: GrantSet.participator)
          membership.user
        end

        def create_initiator(record, user = nil)
          membership = create_group_membership(record, user)
          create(:grant, edge: record, group: membership.group, grant_set: GrantSet.initiator)
          membership.user
        end

        def create_administrator(record, user = nil)
          page = record.is_a?(Page) ? record : record.root

          create_group_membership(record, user, page.groups.find_by(name: 'Admins')).user
        end

        def create_follower(item, user = nil)
          user ||= create(:user)
          create(:follow, followable: item, follower: user)
          user
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def create_resource(klass, attributes = {}, **options)
          parent_edge = attributes.delete(:parent)
          ActsAsTenant.with_tenant(parent_edge&.root || ActsAsTenant.current_tenant) do
            attributes[:owner_type] = klass.to_s if klass < Edge

            options = service_options(creator: options[:creator], publisher: options[:publisher])
            ActsAsTenant.current_tenant&.join_user(options[:user_context].user)
            service_class = "Create#{klass}".safe_constantize || service_class_fallback(klass)
            service = service_class.new(
              parent_edge,
              attributes: attributes,
              options: options
            )
            service.commit
            raise service.resource.errors.full_messages.first unless service.resource.valid?

            service.resource.try(:store_in_redis?) ? service.resource : service.resource.reload
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def service_options(publisher: nil, creator: nil)
          user = publisher || create(:user, confirmed_at: Time.current)
          profile = creator || user.profile
          user_context = UserContext.new(
            user: user,
            profile: profile,
            session_id: user.try(:session_id)
          )

          {user_context: user_context}
        end

        def destroy_resource(resource, user = nil, profile = nil) # rubocop:disable Metrics/MethodLength
          ActsAsTenant.with_tenant(resource&.root || ActsAsTenant.current_tenant) do
            service_class = "Destroy#{resource.class}".safe_constantize || DestroyService
            options = service_options(publisher: user, creator: profile)
            service = service_class.new(
              resource,
              attributes: {},
              options: options
            )
            service.subscribe(ActivityListener.new(**options))
            service.commit
            nil
          end
        end

        def open_file(filename)
          File.open("test/files/#{filename}")
        end

        def parent_iri_for(resource)
          resource.root_relative_iri.to_s[1..]
        end

        def reindex_tree(page = argu)
          Thread.current[:mock_searchkick] = false
          ActsAsTenant.with_tenant(page) do
            Edge.reindex_with_tenant(async: false)
          end
          Thread.current[:mock_searchkick] = true
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

        def trash_resource(resource, user = nil, profile = nil) # rubocop:disable Metrics/MethodLength
          ActsAsTenant.with_tenant(resource&.root || ActsAsTenant.current_tenant) do
            service_class = "Trash#{resource.class}".safe_constantize || TrashService
            options = service_options(publisher: user, creator: profile)
            service = service_class.new(
              resource,
              attributes: {},
              options: options
            )
            service.subscribe(ActivityListener.new(**options))
            service.commit
            resource.reload
          end
        end

        def update_resource(resource, attributes = {}, user = nil, profile = nil) # rubocop:disable Metrics/MethodLength
          ActsAsTenant.with_tenant(resource&.root || ActsAsTenant.current_tenant) do
            service_class = "Update#{resource.class}".safe_constantize || UpdateService
            options = service_options(publisher: user, creator: profile)
            service = service_class.new(
              resource,
              attributes: attributes,
              options: options
            )
            service.subscribe(ActivityListener.new(**options))
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
          let(:frontend_application) { create(:application, scopes: %i[guest user staff]) }
          let(:other_page) { Page.find_via_shortname('other_page') }
          let(:other_page_forum) { Forum.find_via_shortname('other_page_forum') }
          let(:other_forum) { Forum.find_via_shortname('holland') }
          define_freetown_spec_objects
          define_hidden_spec_objects
        end

        def define_freetown_spec_objects # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          let(:freetown) { Forum.find_via_shortname('freetown') }
          let(:group) { Group.find_by(name: 'custom') }
          let(:group_membership) { group.group_memberships.first }
          let(:forum_motion) { freetown.motions.first }
          let(:question) { freetown.questions.first }
          let(:motion) { question.motions.first }
          let(:forum_topic) { freetown.topics.first }
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
          let(:page_export) { argu.exports.first }
          let(:forum_export) { freetown.exports.first }
          let(:motion_export) { motion.exports.first }
        end

        def define_hidden_spec_objects
          let(:holland) { Forum.find_via_shortname('holland') }
          let(:hidden_motion) { holland.descendants.at_depth(4).where(owner_type: 'Motion').first }
        end

        def define_model_spec_objects
          let(:described_method) do |example|
            desc = ([example.example_group] + example.example_group.parent_groups)
                     .map(&:description)
                     .detect { |name| name.starts_with?('#') }

            desc[1..].to_sym if desc.is_a?(String) && desc != '#initialize'
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
