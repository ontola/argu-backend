# frozen_string_literal: true

RSpec.shared_examples_for 'get new' do |opts = {skip: []}|
  let(:r_param) { new_path }

  (new_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:new_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(:guest, doorkeeper_application(format))
          get new_path, headers: request_headers(format)
          send("expect_get_new_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:new_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user, doorkeeper_application(format))
          get new_path, headers: request_headers(format)
          send("expect_get_new_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:new_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user, doorkeeper_application(format))
          get new_path, headers: request_headers(format)
          send("expect_get_new_#{format}")
        end
      end

      unless opts[:skip].include?(:new_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing parent' do
          sign_in(authorized_user, doorkeeper_application(format))
          get non_existing_new_path, headers: request_headers(format)
          expect_not_found
        end
      end
    end
  end
end
