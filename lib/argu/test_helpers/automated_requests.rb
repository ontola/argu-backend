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

      module ClassMethods # rubocop:disable Metrics/ModuleLength
        def expectations_for(action)
          %i[json_api].concat(RDF_CONTENT_TYPES) .each do |format|
            let("expect_#{action}_#{format}") { send("expect_#{action}_serializer") }
            let("expect_#{action}_guest_#{format}") { send("expect_#{action}_guest_serializer") }
            let("expect_#{action}_unauthorized_#{format}") { send("expect_#{action}_unauthorized_serializer") }
            let("expect_#{action}_failed_#{format}") { send("expect_#{action}_failed_serializer") }
          end
        end

        def define_spec_variables # rubocop:disable Metrics/AbcSize
          let(:request_format) { :html }
          let(:doorkeeper_application) do
            if %i[html json].include?(request_format)
              Doorkeeper::Application.argu
            else
              Doorkeeper::Application.argu_front_end
            end
          end

          # Differences
          let(:create_differences) { {"#{subject.class}.count" => 1, 'Activity.count' => 1} }
          let(:create_guest_differences) { {} }
          let(:update_differences) { {"#{subject.class}.count" => 0, 'Activity.count' => 1} }
          let(:destroy_differences) { {"#{subject.class}.count" => -1, 'Activity.count' => 1} }
          let(:trash_differences) { {"#{subject.class}.trashed.count" => 1, 'Activity.count' => 1} }
          let(:untrash_differences) { {"#{subject.class}.trashed.count" => -1, 'Activity.count' => 1} }
          let(:no_differences) { {"#{subject.class}.count" => 0, 'Activity.count' => 0} }

          # Expectations
          let(:expect_success) { expect(response.code).to eq('200') }
          let(:expect_created) { expect(response.code).to eq('201') }
          let(:expect_not_a_user) { expect(response.code).to eq('401') }
          let(:expect_unauthorized) { expect(response.code).to eq('403') }
          let(:expect_not_found) { expect(response.code).to eq('404') }
          let(:expect_redirect_to_login) do
            expect(response).to redirect_to(new_user_session_path(r: path_with_hostname(r_param)))
          end

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
          let(:expect_delete_trash_json_api) { expect(response.code).to eq('204') }
          let(:expect_delete_trash_serializer) { expect(response.code).to eq('200') }

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
          let(:expect_put_untrash_html) { expect(response).to redirect_to(subject.iri.path) }
          let(:expect_put_untrash_json_api) { expect(response.code).to eq('204') }
          let(:expect_put_untrash_serializer) { expect(response.code).to eq('200') }

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
          let(:expect_put_update_serializer) { expect(response.code).to eq('200') }
          let(:expect_put_update_json_api) { expect(response.code).to eq('204') }
          let(:expect_put_update_failed_html) do
            expect_success
            invalid_update_params[class_sym].each_value { |v| expect(response.body).to(include(v)) }
          end
          let(:expect_put_update_failed_serializer) { expect(response.code).to eq('422') }

          # Move
          expectations_for(:post_move)
          let(:expect_post_move_guest_html) { expect_redirect_to_login }
          let(:expect_post_move_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_post_move_unauthorized_html) { expect_unauthorized }
          let(:expect_post_move_unauthorized_serializer) { expect_unauthorized }
          let(:expect_post_move) do
            subject.reload
            assert_equal other_page_forum, subject_parent
            case subject
            when Motion
              assert subject.arguments.count.positive?
            when Question
              assert subject.motions.count.positive?
            end
            assert subject.activities.count.positive?
            subject.activities.pluck(:recipient_id).each do |id|
              assert_equal other_page_forum.id, id
            end
            subject.activities.pluck(:recipient_type).each do |type|
              assert_equal 'Forum', type
            end
          end

          # Forms
          expectations_for(:get_form)
          let(:expect_get_form_guest_html) { expect_redirect_to_login }
          let(:expect_get_form_guest_serializer) { expect(response.code).to eq('401') }
          let(:expect_get_form_unauthorized_html) { expect_unauthorized }
          let(:expect_get_form_unauthorized_serializer) { expect_unauthorized }
          let(:expect_get_form_html) { expect_success }
          let(:expect_get_form_serializer) { expect_success }

          # Users
          let(:staff) { EmailAddress.find_by(email: 'staff@example.com').user }
          let(:authorized_user) { create_administrator(argu, create(:user)) }
          let(:authorized_user_update) { authorized_user }
          let(:authorized_user_destroy) { staff }
          let(:authorized_user_trash) { authorized_user_update }
          let(:unauthorized_user) do
            holland.grants.destroy_all
            freetown.grants.destroy_all
            create_forum(public_grant: 'participator', parent: create(:page))
            create(:user)
          end

          let(:subject_parent) { subject.parent }
          # Symbols
          let(:class_sym) { subject.class.name.underscore.to_sym }
          let(:table_sym) { subject.class.name.tableize.to_sym }
          let(:parent_class_sym) { subject_parent.class.name.underscore.to_sym }
          let(:parent_table_sym) do
            subject_parent.is_a?(Forum) ? :container_nodes : subject_parent.class.name.tableize.to_sym
          end

          # Params
          let(:required_keys) { %w[title] }
          let(:create_params) { {class_sym => attributes_for(class_sym)} }
          let(:non_existing_create_params) { create_params }
          let(:invalid_create_params) { {class_sym => Hash[required_keys.map { |k| [k, '1'] }]} }
          let(:update_params) { {class_sym => Hash[required_keys.map { |k| [k, '12345'] }]} }
          let(:invalid_update_params) { invalid_create_params }
          let(:move_params) { {move: {new_parent_id: other_page_forum.uuid}} }
          let(:destroy_params) { {} }

          # Paths
          let(:index_path) { collection_iri(subject_parent, table_sym).path }
          let(:create_path) { index_path }
          let(:new_path) { new_iri(create_path).path }
          let(:show_path) { resource_iri(subject).path }
          let(:destroy_path) { "#{resource_iri(subject).path}?destroy=true" }
          let(:edit_path) { edit_iri(show_path).path }
          let(:shift_path) { new_iri(move_path).path }
          let(:move_path) { resource_iri(Move.new(edge: subject)).path }
          let(:update_path) { show_path }
          let(:delete_path) { delete_iri(show_path).path }
          let(:trash_path) { show_path }
          let(:untrash_path) { untrash_iri(show_path).path }

          # Non existing paths
          let(:non_existing_id) { -99 }
          let(:non_existing_index_path) do
            collection_iri(
              expand_uri_template("#{parent_table_sym}_iri", id: non_existing_id, root_id: argu.url),
              table_sym,
              root: argu
            ).path
          end
          let(:non_existing_create_path) { non_existing_index_path }
          let(:non_existing_new_path) { new_iri(non_existing_create_path).path }
          let(:non_existing_show_path) do
            expand_uri_template("#{table_sym}_iri", id: non_existing_id, root_id: argu.url)
          end
          let(:non_existing_destroy_path) do
            expand_uri_template("#{table_sym}_iri", id: -99, root_id: argu.url, destroy: true)
          end
          let(:non_existing_edit_path) { edit_iri(non_existing_show_path, root: argu).path }
          let(:non_existing_shift_path) { new_iri(non_existing_move_path, root: argu).path }
          let(:non_existing_move_path) do
            expand_uri_template(:moves_iri, parent_iri: split_iri_segments(non_existing_show_path))
          end
          let(:non_existing_update_path) { non_existing_show_path }
          let(:non_existing_delete_path) { delete_iri(non_existing_show_path, root: argu).path }
          let(:non_existing_trash_path) { non_existing_show_path }
          let(:non_existing_untrash_path) { untrash_iri(non_existing_show_path, root: argu).path }

          # Result paths
          let(:parent_path) { subject_parent.iri.path }
          let(:created_resource_path) { subject.class.last.iri.path }
          let(:updated_resource_path) { show_path }
          let(:create_failed_path) { parent_path }
          let(:update_failed_path) { updated_resource_path }
          let(:destroy_failed_path) { update_failed_path }
          let(:move_failed_path) { update_failed_path }
        end

        def default_formats
          %i[html json_api].concat((RDF_CONTENT_TYPES - [:ttl]).shuffle[1..2])
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
          default_formats - [:json_api]
        end

        def edit_formats
          default_formats - [:json_api]
        end

        def delete_formats
          default_formats - [:json_api]
        end

        def move_formats
          default_formats - [:json_api]
        end

        def shift_formats
          default_formats - [:json_api]
        end
      end
    end
  end
end
