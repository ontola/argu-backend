# frozen_string_literal: true

Dir[Rails.root.join('spec', 'shared_examples', '*.rb')].each { |f| require f }

module Argu
  module TestHelpers
    module AutomatedRequests
      def self.included(base)
        base.extend(ClassMethods)
        base.define_spec_variables
        base.define_spec_objects
      end

      module ClassMethods
        def define_spec_variables
          # Differences
          let(:create_differences) { [["#{subject.class}.count", 1], ['Activity.loggings.count', 1]] }
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
          let(:expect_unauthorized) { expect(response.code).to eq('403') }
          let(:expect_not_found) { expect(response.code).to eq('404') }
          let(:expect_redirect_to_login) { expect(response).to redirect_to(new_user_session_path(r: r_param)) }

          let(:expect_get_index) { expect_success }
          let(:expect_get_new) { expect_success }
          let(:expect_get_edit) { expect_success }
          let(:expect_get_delete) { expect_success }
          let(:expect_get_shift) { expect_success }

          let(:expect_get_show_guest_html) { expect_get_show_html }
          let(:expect_get_show_guest_json_api) { expect_get_show_json_api }
          let(:expect_get_show_guest_nt) { expect_get_show_guest_json_api }
          let(:expect_get_show_unauthorized_html) { expect_unauthorized }
          let(:expect_get_show_unauthorized_json_api) { expect_unauthorized }
          let(:expect_get_show_unauthorized_nt) { expect_get_show_unauthorized_json_api }
          let(:expect_get_show_html) { expect_success }
          let(:expect_get_show_json_api) { expect_success }
          let(:expect_get_show_nt) { expect_get_show_json_api }

          let(:expect_get_index_guest_html) { expect_get_index_html }
          let(:expect_get_index_guest_json_api) { expect_get_index_json_api }
          let(:expect_get_index_guest_nt) { expect_get_index_guest_json_api }
          let(:expect_get_index_unauthorized_html) { expect_unauthorized }
          let(:expect_get_index_unauthorized_json_api) { expect_unauthorized }
          let(:expect_get_index_unauthorized_nt) { expect_get_index_unauthorized_json_api }
          let(:expect_get_index_html) { expect_success }
          let(:expect_get_index_json_api) { expect_success }
          let(:expect_get_index_nt) { expect_get_index_json_api }

          let(:expect_delete_destroy_guest_html) { expect_redirect_to_login }
          let(:expect_delete_destroy_guest_json_api) { expect(response.code).to eq('401') }
          let(:expect_delete_destroy_guest_nt) { expect_delete_destroy_guest_json_api }
          let(:expect_delete_destroy_unauthorized_html) { expect_unauthorized }
          let(:expect_delete_destroy_unauthorized_json_api) { expect_unauthorized }
          let(:expect_delete_destroy_unauthorized_nt) { expect_delete_destroy_unauthorized_json_api }
          let(:expect_delete_destroy_html) do
            expect(response.code).to eq('303')
            expect(response).to redirect_to(parent_path)
          end
          let(:expect_delete_destroy_json_api) { expect(response.code).to eq('204') }
          let(:expect_delete_destroy_nt) { expect_delete_destroy_json_api }

          let(:expect_delete_trash_guest_html) { expect_redirect_to_login }
          let(:expect_delete_trash_guest_json_api) { expect(response.code).to eq('401') }
          let(:expect_delete_trash_guest_nt) { expect_delete_trash_guest_json_api }
          let(:expect_delete_trash_unauthorized_html) { expect_unauthorized }
          let(:expect_delete_trash_unauthorized_json_api) { expect_unauthorized }
          let(:expect_delete_trash_unauthorized_nt) { expect_delete_trash_unauthorized_json_api }
          let(:expect_delete_trash_html) { expect(response).to redirect_to(show_path) }
          let(:expect_delete_trash_json_api) { expect(response.code).to eq('204') }
          let(:expect_delete_trash_nt) { expect_delete_trash_json_api }

          let(:expect_post_create_guest_html) { expect_redirect_to_login }
          let(:expect_post_create_guest_json_api) { expect(response.code).to eq('401') }
          let(:expect_post_create_guest_nt) { expect_post_create_guest_json_api }
          let(:expect_post_create_unauthorized_html) { expect_unauthorized }
          let(:expect_post_create_unauthorized_json_api) { expect_unauthorized }
          let(:expect_post_create_unauthorized_nt) { expect_post_create_unauthorized_json_api }
          let(:expect_post_create_html) { expect(response).to redirect_to(created_resource_path) }
          let(:expect_post_create_json_api) { expect_created }
          let(:expect_post_create_nt) { expect_post_create_json_api }
          let(:expect_post_create_failed_html) do
            expect_success
            invalid_create_params[class_sym].each { |_k, v| expect(response.body).to(include(v)) }
          end
          let(:expect_post_create_failed_json_api) { expect(response.code).to eq('422') }
          let(:expect_post_create_failed_nt) { expect_post_create_failed_json_api }

          let(:expect_put_untrash_guest_html) { expect_redirect_to_login }
          let(:expect_put_untrash_guest_json_api) { expect(response.code).to eq('401') }
          let(:expect_put_untrash_guest_nt) { expect_put_untrash_guest_json_api }
          let(:expect_put_untrash_unauthorized_html) { expect_unauthorized }
          let(:expect_put_untrash_unauthorized_json_api) { expect_unauthorized }
          let(:expect_put_untrash_unauthorized_nt) { expect_put_untrash_unauthorized_json_api }
          let(:expect_put_untrash_html) { expect(response).to redirect_to(url_for(subject)) }
          let(:expect_put_untrash_json_api) { expect(response.code).to eq('204') }
          let(:expect_put_untrash_nt) { expect_put_untrash_json_api }

          let(:expect_put_update_guest_html) { expect_redirect_to_login }
          let(:expect_put_update_guest_json_api) { expect(response.code).to eq('401') }
          let(:expect_put_update_guest_nt) { expect_put_update_guest_json_api }
          let(:expect_put_update_unauthorized_html) { expect_unauthorized }
          let(:expect_put_update_unauthorized_json_api) { expect_unauthorized }
          let(:expect_put_update_unauthorized_nt) { expect_put_update_unauthorized_json_api }
          let(:expect_put_update_html) do
            expect(response).to redirect_to(updated_resource_path)
            subject.reload
            update_params[class_sym].each { |k, v| expect(subject.send(k)).to eq(v) }
          end
          let(:expect_put_update_json_api) { expect(response.code).to eq('204') }
          let(:expect_put_update_nt) { expect_put_update_json_api }
          let(:expect_put_update_failed_html) do
            expect_success
            invalid_update_params[class_sym].each { |_k, v| expect(response.body).to(include(v)) }
          end
          let(:expect_put_update_failed_json_api) { expect(response.code).to eq('422') }
          let(:expect_put_update_failed_nt) { expect_put_update_failed_json_api }

          let(:expect_put_move_guest_html) { expect_redirect_to_login }
          let(:expect_put_move_guest_json_api) { expect(response.code).to eq('401') }
          let(:expect_put_move_guest_nt) { expect_put_move_guest_json_api }
          let(:expect_put_move_unauthorized_html) { expect_unauthorized }
          let(:expect_put_move_unauthorized_json_api) { expect_unauthorized }
          let(:expect_put_move_unauthorized_nt) { expect_put_move_unauthorized_json_api }
          let(:expect_put_move) do
            expect(response).to redirect_to(show_path)
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
                assert_equal record.forum.id, id
              end
              assert subject.reload.motions.blank?
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
          let(:staff) { create(:user, :staff) }
          let(:authorized_user) { create_administrator(argu, create(:user)) }
          let(:authorized_user_update) { authorized_user }
          let(:authorized_user_trash) { authorized_user_update }
          let(:unauthorized_user) do
            public_source.edge.grants.destroy_all
            holland.edge.grants.destroy_all
            freetown.edge.grants.destroy_all
            create_forum(public_grant: 'participator')
            create(:user)
          end

          # Symbols
          let(:class_sym) { subject.class.name.underscore.to_sym }
          let(:table_sym) { subject.class.name.tableize.to_sym }
          let(:parent_class_sym) { subject.parent_model.class.name.underscore.to_sym }

          # Params
          let(:required_keys) { %w[title] }
          let(:create_params) { {class_sym => attributes_for(class_sym)} }
          let(:non_existing_create_params) { create_params }
          let(:invalid_create_params) { {class_sym => Hash[required_keys.map { |k| [k, '1'] }]} }
          let(:update_params) { {class_sym => Hash[required_keys.map { |k| [k, '12345'] }]} }
          let(:invalid_update_params) { invalid_create_params }
          let(:move_params) { {class_sym => {forum_id: other_page_forum.id}} }
          let(:destroy_params) { {} }

          # Paths
          let(:new_path) { url_for([:new, subject.parent_model, class_sym, only_path: true]) }
          let(:edit_path) { url_for([:edit, subject, only_path: true]) }
          let(:index_path) { url_for([subject.parent_model, table_sym, only_path: true]) }
          let(:show_path) { url_for([subject, only_path: true]) }
          let(:create_path) { url_for([subject.parent_model, table_sym, only_path: true]) }
          let(:update_path) { url_for([subject, only_path: true]) }
          let(:delete_path) { url_for([:delete, subject, only_path: true]) }
          let(:destroy_path) { url_for([subject, destroy: true, only_path: true]) }
          let(:trash_path) { url_for([subject, only_path: true]) }
          let(:untrash_path) { url_for([:untrash, subject, only_path: true]) }
          let(:shift_path) { url_for([subject, :move, only_path: true]) }
          let(:move_path) { shift_path }

          # Non existing paths
          let(:non_existing_new_path) do
            url_for([:new, parent_class_sym, class_sym, "#{parent_class_sym}_id".to_sym => -1, only_path: true])
          end
          let(:non_existing_edit_path) { url_for([:edit, class_sym, id: -1, only_path: true]) }
          let(:non_existing_shift_path) { url_for([class_sym, :move, "#{class_sym}_id".to_sym => -1, only_path: true]) }
          let(:non_existing_move_path) { non_existing_shift_path }
          let(:non_existing_index_path) do
            url_for([parent_class_sym, table_sym, "#{parent_class_sym}_id".to_sym => -1, only_path: true])
          end
          let(:non_existing_show_path) { url_for([class_sym, id: -1, only_path: true]) }
          let(:non_existing_create_path) do
            url_for([parent_class_sym, table_sym, "#{parent_class_sym}_id".to_sym => -1, only_path: true])
          end
          let(:non_existing_update_path) { url_for([class_sym, id: -1, only_path: true]) }
          let(:non_existing_delete_path) { url_for([:delete, class_sym, id: -1, only_path: true]) }
          let(:non_existing_destroy_path) { url_for([class_sym, id: -1, destroy: true, only_path: true]) }
          let(:non_existing_trash_path) { url_for([class_sym, id: -1, only_path: true]) }
          let(:non_existing_untrash_path) { url_for([:untrash, class_sym, id: -1, only_path: true]) }

          # Result paths
          let(:parent_path) { url_for([subject.parent_model, only_path: true]) }
          let(:created_resource_path) { url_for([subject.class.last, only_path: true]) }
          let(:updated_resource_path) { show_path }
          let(:create_failed_path) { parent_path }
          let(:update_failed_path) { updated_resource_path }
          let(:move_failed_path) { update_failed_path }
        end
      end
    end
  end
end
