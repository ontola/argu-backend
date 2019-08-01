# frozen_string_literal: true

RSpec.shared_examples_for 'get show' do |opts = {skip: []}|
  (show_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:show_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(:guest, doorkeeper_application(format))
          get show_path, headers: request_headers(format)
          send("expect_get_show_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:show_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user, doorkeeper_application(format))
          get show_path, headers: request_headers(format)
          send("expect_get_show_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:show_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_update, doorkeeper_application(format))
          get show_path, headers: request_headers(format)
          send("expect_get_show_#{format}")
        end
      end

      unless opts[:skip].include?(:show_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_update, doorkeeper_application(format))
          get non_existing_show_path, headers: request_headers(format)
          expect_not_found
        end
      end
    end
  end
end
