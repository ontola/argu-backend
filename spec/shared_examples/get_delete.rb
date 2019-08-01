# frozen_string_literal: true

RSpec.shared_examples_for 'get delete' do |opts = {skip: []}|
  let(:r_param) { delete_path }
  let(:authorized_user) { staff }

  (delete_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:delete_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(:guest, doorkeeper_application(format))
          get delete_path, headers: request_headers(format)
          send("expect_get_form_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:delete_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user, doorkeeper_application(format))
          get delete_path, headers: request_headers(format)
          send("expect_get_form_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:delete_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user, doorkeeper_application(format))
          get delete_path, headers: request_headers(format)
          send("expect_get_form_#{format}")
        end
      end

      unless opts[:skip].include?(:delete_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user, doorkeeper_application(format))
          get non_existing_delete_path, headers: request_headers(format)
          expect_not_found
        end
      end
    end
  end
end
