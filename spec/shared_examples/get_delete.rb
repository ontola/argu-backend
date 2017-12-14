# frozen_string_literal: true

RSpec.shared_examples_for 'get delete' do |opts = {skip: []}|
  let(:r_param) { delete_path }
  let(:authorized_user) { staff }

  delete_formats.each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:delete_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          get delete_path
          expect_redirect_to_login
        end
      end

      unless opts[:skip].include?(:delete_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          get delete_path
          expect_unauthorized
        end
      end

      unless opts[:skip].include?(:delete_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user)
          get delete_path
          expect_get_delete
        end
      end

      unless opts[:skip].include?(:delete_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user)
          get non_existing_delete_path
          expect_not_found
        end
      end
    end
  end
end
