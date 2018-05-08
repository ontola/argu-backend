# frozen_string_literal: true

Dir[Rails.root.join('spec', 'shared_examples', '*.rb')].each { |f| require f }

module Argu
  module TestHelpers
    module AutomatedRequests
      include UriTemplateHelper

      def self.included(base)
        base.extend(ClassMethods)
        base.define_spec_variables
        base.define_spec_objects
      end

      module ClassMethods
        def expectations_for(action)
          %i[json_api].concat(RDF_CONTENT_TYPES) .each do |format|
            let("expect_#{action}_#{format}") { send("expect_#{action}_serializer") }
            let("expect_#{action}_guest_#{format}") { send("expect_#{action}_guest_serializer") }
            let("expect_#{action}_unauthorized_#{format}") { send("expect_#{action}_unauthorized_serializer") }
            let("expect_#{action}_failed_#{format}") { send("expect_#{action}_failed_serializer") }
          end
        end

        def define_spec_variables
          let(:request_format) { :html }

          # Differences
          let(:create_differences) { [["#{subject.class}.count", 1], ['Activity.loggings.count', 1]] }
          let(:create_guest_differences) { [] }
          let(:update_differences) { [["#{subject.class}.count", 0], ['Activity.loggings.count', 1]] }
          let(:move_differences) do
            [
              ["freetown.reload.#{subject.class_name}.count", -1],
              ["other_page_forum.reload.#{subject.class_name}.count", 1]
            ]
          end
          let(:destroy_differences) { [["#{subject.class}.count", -1], ['Activity.loggings.count', 1]] }
          let(:trash_differences) { [["#{subject.class}.trashed.count", 1], ['Activity.loggings.count', 1]] }
          let(:untrash_differences) { [["#{subject.class}.trashed.count", -1], ['Activity.loggings.count', 1]] }
          let(:no_differences) { [["#{subject.class}.count", 0], ['Activity.loggings.count', 0]] }

          # Expectations
          let(:expect_success) { expect(response.code).to eq('200') }
          let(:expect_created) { expect(response.code).to eq('201') }
          let(:expect_not_a_user) { expect(response.code).to eq('401') }
          let(:expect_unauthorized) { expect(response.code).to eq('403') }
          let(:expect_not_found) { expect(response.code).to eq('404') }
          let(:expect_redirect_to_login) { expect(response).to redirect_to(new_user_session_path(r: r_param)) }

          let(:expect_get_index) { expect_success }
          let(:expect_get_new) { expect_success }
          let(:expect_get_edit) { expect_success }
          let(:expect_get_delete) { expect_success }
          let(:expect_get_shift) { expect_success }

          # Show
          expectations_for(:get_show)
          let(:expect_get_show_guest_html) { expect_get_show_html }
          let(:expect_get_show_guest_serializer) { expect_get_show_serializer }
          let(:expect_get_show_unauthorized_html) { expect_unauthorized }
          let(:expect_get_show_unauthorized_serializer) { expect_unauthorized }
          let(:expect_get_show_html) { expect_success }
          let(:expect_get_show_serializer) { expect_success }

          # Index
          expectations_for(:get_index)
          let(:expect_get_index_guest_html) { expect_get_index_html }
          let(:expect_get_index_guest_serializer) { expect_get_index_serializer }
          let(:expect_get_index_unauthorized_html) { expect_unauthorized }
          let(:expect_get_index_unauthorized_serializer) { expect_unauthorized }
          let(:expect_get_index_html) { expect_success }
          let(:expect_get_index_serializer) { expect_success }

          # Destroy
          expectations_for(:delete_destroy)
          let(:expect_delete_destroy_guest_html) { expect_redirect_to_login }
          let(:expect_delete_destroy_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_delete_destroy_unauthorized_html) { expect_unauthorized }
          let(:expect_delete_destroy_unauthorized_serializer) { expect_unauthorized }
          let(:expect_delete_destroy_html) do
            expect(response.code).to eq('303')
            expect(response).to redirect_to(parent_path)
          end
          let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }
          let(:expect_delete_destroy_serializer) { expect(response.code).to eq('200') }

          # Trash
          expectations_for(:delete_trash)
          let(:expect_delete_trash_guest_html) { expect_redirect_to_login }
          let(:expect_delete_trash_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_delete_trash_unauthorized_html) { expect_unauthorized }
          let(:expect_delete_trash_unauthorized_serializer) { expect_unauthorized }
          let(:expect_delete_trash_html) { expect(response).to redirect_to(show_path) }
          let(:expect_delete_trash_serializer) { expect(response.code).to eq('204') }

          # Create
          expectations_for(:post_create)
          let(:expect_post_create_guest_html) { expect_redirect_to_login }
          let(:expect_post_create_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_post_create_unauthorized_html) { expect_unauthorized }
          let(:expect_post_create_unauthorized_serializer) { expect_unauthorized }
          let(:expect_post_create_html) { expect(response).to redirect_to(created_resource_path) }
          let(:expect_post_create_serializer) { expect_created }
          let(:expect_post_create_failed_html) do
            expect_success
            invalid_create_params[class_sym].each_value { |v| expect(response.body).to(include(v)) }
          end
          let(:expect_post_create_failed_serializer) { expect(response.code).to eq('422') }

          # Untrash
          expectations_for(:put_untrash)
          let(:expect_put_untrash_guest_html) { expect_redirect_to_login }
          let(:expect_put_untrash_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_put_untrash_unauthorized_html) { expect_unauthorized }
          let(:expect_put_untrash_unauthorized_serializer) { expect_unauthorized }
          let(:expect_put_untrash_html) { expect(response).to redirect_to(subject.iri_path) }
          let(:expect_put_untrash_serializer) { expect(response.code).to eq('204') }

          # Update
          expectations_for(:put_update)
          let(:expect_put_update_guest_html) { expect_redirect_to_login }
          let(:expect_put_update_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_put_update_unauthorized_html) { expect_unauthorized }
          let(:expect_put_update_unauthorized_serializer) { expect_unauthorized }
          let(:expect_put_update_html) do
            expect(response).to redirect_to(updated_resource_path)
            subject.reload
            update_params[class_sym].each { |k, v| expect(subject.send(k)).to eq(v) }
          end
          let(:expect_put_update_serializer) { expect(response.code).to eq('204') }
          let(:expect_put_update_failed_html) do
            expect_success
            invalid_update_params[class_sym].each_value { |v| expect(response.body).to(include(v)) }
          end
          let(:expect_put_update_failed_serializer) { expect(response.code).to eq('422') }

          # Move
          expectations_for(:put_move)
          let(:expect_put_move_guest_html) { expect_redirect_to_login }
          let(:expect_put_move_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_put_move_unauthorized_html) { expect_unauthorized }
          let(:expect_put_move_unauthorized_serializer) { expect_unauthorized }
          let(:expect_put_move) do
            expect(response).to redirect_to(subject.reload.iri_path)
            subject.reload
            assert_equal other_page_forum, subject.forum
            assert_equal other_page_forum, subject.parent_model
            case subject
            when Motion
              assert subject.arguments.count.positive?
              subject.arguments.pluck(:forum_id).each do |id|
                assert_equal other_page_forum.id, id
              end
            when Question
              subject.motions.pluck(:forum_id).each do |id|
                assert_equal subject.forum.id, id
              end
              assert subject.reload.motions.present?
            end
            assert subject.activities.count.positive?
            subject.activities.pluck(:forum_id).each do |id|
              assert_equal other_page_forum.id, id
            end
            subject.activities.pluck(:recipient_id).each do |id|
              assert_equal other_page_forum.id, id
            end
            subject.activities.pluck(:recipient_type).each do |type|
              assert_equal 'Forum', type
            end
          end

          # Users
          let(:staff) { EmailAddress.find_by(email: 'staff@example.com').user }
          let(:authorized_user) { create_administrator(argu, create(:user)) }
          let(:authorized_user_update) { authorized_user }
          let(:authorized_user_destroy) { staff }
          let(:authorized_user_trash) { authorized_user_update }
          let(:unauthorized_user) do
            holland.edge.grants.destroy_all
            freetown.edge.grants.destroy_all
            create_forum(public_grant: 'participator')
            create(:user)
          end

          # Symbols
          let(:class_sym) { subject.class.name.underscore.to_sym }
          let(:table_sym) { subject.class.name.tableize.to_sym }
          let(:parent_class_sym) { subject.parent_model.class.name.underscore.to_sym }
          let(:parent_table_sym) { subject.parent_model.class.name.tableize.to_sym }

          # Params
          let(:required_keys) { %w[title] }
          let(:create_params) { {class_sym => attributes_for(class_sym)} }
          let(:non_existing_create_params) { create_params }
          let(:invalid_create_params) { {class_sym => Hash[required_keys.map { |k| [k, '1'] }]} }
          let(:update_params) { {class_sym => Hash[required_keys.map { |k| [k, '12345'] }]} }
          let(:invalid_update_params) { invalid_create_params }
          let(:move_params) { {edge_id: other_page_forum.edge.id} }
          let(:destroy_params) { {} }

          # Paths
          let(:index_path) { collection_iri_path(subject.parent_model, table_sym) }
          let(:create_path) { index_path }
          let(:new_path) { new_iri_path(create_path) }
          let(:show_path) { subject.iri_path }
          let(:destroy_path) { subject.iri_path(destroy: true) }
          let(:edit_path) { edit_iri_path(show_path) }
          let(:shift_path) { move_iri_path(show_path) }
          let(:move_path) { shift_path }
          let(:update_path) { show_path }
          let(:delete_path) { delete_iri_path(show_path) }
          let(:trash_path) { show_path }
          let(:untrash_path) { untrash_iri_path(show_path) }

          # Non existing paths
          let(:non_existing_index_path) do
            collection_iri_path(expand_uri_template("#{parent_table_sym}_iri", id: -99, only_path: true), table_sym)
          end
          let(:non_existing_create_path) { non_existing_index_path }
          let(:non_existing_new_path) { new_iri_path(non_existing_create_path) }
          let(:non_existing_show_path) { expand_uri_template("#{table_sym}_iri", id: -99, only_path: true) }
          let(:non_existing_destroy_path) do
            expand_uri_template("#{table_sym}_iri", id: -99, only_path: true, destroy: true)
          end
          let(:non_existing_edit_path) { edit_iri_path(non_existing_show_path) }
          let(:non_existing_shift_path) { move_iri_path(non_existing_show_path) }
          let(:non_existing_move_path) { non_existing_shift_path }
          let(:non_existing_update_path) { non_existing_show_path }
          let(:non_existing_delete_path) { delete_iri_path(non_existing_show_path) }
          let(:non_existing_trash_path) { non_existing_show_path }
          let(:non_existing_untrash_path) { untrash_iri_path(non_existing_show_path) }

          # Result paths
          let(:parent_path) { subject.parent_model.iri_path }
          let(:created_resource_path) { subject.class.last.iri_path }
          let(:updated_resource_path) { show_path }
          let(:create_failed_path) { parent_path }
          let(:update_failed_path) { updated_resource_path }
          let(:destroy_failed_path) { update_failed_path }
          let(:move_failed_path) { update_failed_path }
        end

        def default_formats
          %i[html json_api].concat(RDF_CONTENT_TYPES.shuffle[1..2])
        end

        def show_formats
          default_formats
        end

        def create_formats
          default_formats
        end

        def index_formats
          default_formats
        end

        def destroy_formats
          default_formats
        end

        def trash_formats
          default_formats
        end

        def untrash_formats
          default_formats
        end

        def update_formats
          default_formats
        end

        def new_formats
          %i[html]
        end

        def edit_formats
          %i[html]
        end

        def delete_formats
          %i[html]
        end

        def move_formats
          %i[html]
        end

        def shift_formats
          %i[html]
        end
      end
    end
  end
end
