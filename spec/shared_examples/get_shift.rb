# frozen_string_literal: true

RSpec.shared_examples_for 'get shift' do |opts = {skip: []}|
  let(:r_param) { shift_path }
  let(:authorized_user) { staff }

  (shift_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:shift_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          get shift_path
          expect_redirect_to_login
        end
      end

      unless opts[:skip].include?(:shift_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          get shift_path
          expect_unauthorized
        end
      end

      unless opts[:skip].include?(:shift_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_update)
          get shift_path
          expect_get_shift
        end
      end

      unless opts[:skip].include?(:shift_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_update)
          get non_existing_shift_path
          expect_not_found
        end
      end
    end
  end
end
