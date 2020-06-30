# frozen_string_literal: true

RSpec.shared_examples_for 'get index' do |opts = {skip: []}|
  let(:r_param) { index_path }

  (index_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:index_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(guest_user)
          get index_path, headers: request_headers(format)
          send("expect_get_index_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:index_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          before_unauthorized_index
          sign_in(unauthorized_user)
          get index_path, headers: request_headers(format)
          send("expect_get_index_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:index_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user)
          get index_path, headers: request_headers(format)
          send("expect_get_index_#{format}")
        end
      end

      unless opts[:skip].include?(:index_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing parent' do
          sign_in(authorized_user)
          get non_existing_index_path, headers: request_headers(format)
          expect_not_found
        end
      end
    end
  end
end
