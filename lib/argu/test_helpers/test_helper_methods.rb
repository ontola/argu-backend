# frozen_string_literal: true

# Shared helper method across TestUnit and RSpec
module Argu
  module TestHelpers
    module TestHelperMethods
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend(ClassMethods)
      end

      module InstanceMethods
        def assert_not_a_member
          assert_equal true, assigns(:_not_a_member_caught)
        end

        def assert_not_a_user
          assert_equal true, assigns(:_not_a_user_caught)
        end

        def assert_not_authorized
          assert_equal true, assigns(:_not_authorized_caught)
        end

        def change_actor(actor)
          a = actor.respond_to?(:profile) ? actor.profile : actor
          @controller.instance_variable_set(:@_current_actor, a)
        end

        def create(model_type, *args)
          attributes = HashWithIndifferentAccess.new
          attributes.merge!(args.pop) if args.last.is_a?(Hash)
          if %i(project blog_post question motion argument comment).include?(model_type)
            klass = model_type.to_s.classify.constantize

            options = {}
            options[:publisher] = attributes.delete(:publisher)
            options[:creator] = attributes.delete(:creator)

            attributes.merge!(attributes_for(model_type, attributes))

            if klass.nested_attributes_options?
              klass.nested_attributes_options.keys.each do |association|
                if attributes.include? association
                  attributes["#{association}_attributes"] = attributes.delete(association).attributes
                end
              end
            end

            resource = create_resource(
              klass.new,
              attributes,
              options)

            args.each do |trait|
              TraitListener.new(resource).send(trait)
            end

            if resource.respond_to?(:publications) && resource.publications.present?
              Sidekiq::Testing.inline! do
                Publication.last.send(:reset)
              end
              resource.reload
            end

            resource
          else
            FactoryGirl.create(model_type, *args, attributes)
          end
        end

        def create_manager(forum, user = nil)
          user ||= create(:user)
          create(:managership, forum: forum, profile: user.profile)
          user
        end

        def create_member(forum, user = nil)
          user ||= create(:user)
          create(:membership, forum: forum, profile: user.profile)
          user
        end

        def create_group_member(group, user_or_page = nil)
          user_or_page ||= create_member(group.forum)
          create(:group_membership,
                 group: group,
                 member: user_or_page.profile)
          user_or_page
        end

        def create_moderator(record, user = nil)
          user ||= create(:user)
          forum = record.is_a?(Forum) ? record : record.forum
          create(:stepup, forum: forum, record: record, moderator: create_member(forum, user))
          user
        end

        # Makes the given `User` a manager of the `Page` of the `Forum`
        # Creates one if not given
        # @note overwrites the current owner in the `Page`
        def create_owner(forum, user = nil)
          user ||= create(:user)
          forum.page.owner = user.profile
          assert_equal true, forum.page.save, "Couldn't create owner"
          user
        end

        def create_forum_owner_pair(forum_opts = {}, manager_opts = {})
          user = create(:user, manager_opts)
          forum = create((forum_opts[:type] || :forum),
                         page: create(:page,
                                      owner: user.profile))
          [forum, user]
        end

        def create_resource(resource, attributes = {}, options = {})
          options[:publisher] = create(:user, confirmed_at: DateTime.current) if options[:publisher].nil?
          options[:creator] = options[:publisher].profile if options[:creator].nil?
          service = "Create#{resource.class}".constantize.new(resource, attributes, options)
          service.subscribe(ActivityListener.new(creator: options[:creator],
                                                 publisher: options[:publisher]))
          service.commit
          resource.reload
        end

        def destroy_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          service = "Destroy#{resource.class}".constantize.new(resource)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          nil
        end

        def open_file(filename)
          File.open("test/files/#{filename}")
        end

        def trash_resource(resource, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          service = "Trash#{resource.class}".constantize.new(resource)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end

        def update_resource(resource, attributes = {}, user = nil, profile = nil)
          user ||= create(:user)
          profile ||= user.profile
          service = "Update#{resource.class}".constantize.new(resource, attributes)
          service.subscribe(ActivityListener.new(creator: profile,
                                                 publisher: user))
          service.commit
          resource.reload
        end

        def uploaded_file_object(klass, attribute, file, content_type = 'text/plain')
          filename = File.basename(file.path)
          klass_label = klass.to_s.underscore

          ActionDispatch::Http::UploadedFile.new(
            tempfile: file,
            filename: filename,
            head: %(Content-Disposition: form-data; name="#{klass_label}[#{attribute}]"; filename="#{filename}"),
            content_type: content_type
          )
        end
      end

      module ClassMethods
        def define_common_objects(*let, **opts)
          let(:freetown) { create(:forum, name: 'freetown') } if mdig?(:freetown, let, opts)
          let(:user) { create(:user, opts.dig(:user)) } if mdig?(:user, let, opts)
          let(:member) { create_member(cascaded_forum(:member, opts)) } if mdig?(:member, let, opts)
          let(:manager) { create_manager(cascaded_forum(:manager, opts)) } if mdig?(:manager, let, opts)
          let(:owner) { create_owner(cascaded_forum(:owner, opts)) } if mdig?(:owner, let, opts)
          let(:staff) { create(:user, :staff) } if mdig?(:staff, let, opts)
        end

        # @param [Symbol] key The key to search for.
        # @param [Array] arr Array of options to search in.
        # @param [Hash] opts Options hash to search in.
        # @return [Boolean] Whether `key` is present in arr or hash.
        def mdig?(key, arr, opts)
          arr.include?(key) || opts.include?(key)
        end

        def cascaded_forum(key, opts)
          key && opts.dig(key, :forum) || opts.dig(:forum) || try(:freetown)
        end
      end
    end
  end
end
