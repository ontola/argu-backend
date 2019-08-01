# frozen_string_literal: true

RSpec.shared_examples_for 'delete trash' do |opts = {skip: []}|
  let(:r_param) { update_failed_path }

  (trash_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:trash_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(:guest, doorkeeper_application(format))
          delete trash_path, headers: request_headers(format)
          send("expect_delete_trash_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:trash_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user, doorkeeper_application(format))
          assert_difference(no_differences) do
            delete trash_path, headers: request_headers(format)
          end
          send("expect_delete_trash_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:trash_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_trash, doorkeeper_application(format))
          assert_difference(trash_differences) do
            delete trash_path, headers: request_headers(format)
          end
          send("expect_delete_trash_#{format}")
        end
      end

      unless opts[:skip].include?(:trash_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_trash, doorkeeper_application(format))
          delete non_existing_trash_path, headers: request_headers(format)
          expect_not_found
        end
      end
    end
  end
end
