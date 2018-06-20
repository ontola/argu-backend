# frozen_string_literal: true

RSpec.shared_examples_for 'put update' do |opts = {skip: []}|
  let(:r_param) { update_failed_path }

  (update_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:new_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          put update_path, params: update_params.merge(format: format)
          send("expect_put_update_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:update_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          assert_difference(no_differences) do
            put update_path, params: update_params.merge(format: format)
          end
          send("expect_put_update_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:update_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_update)
          assert_difference(update_differences) do
            put update_path, params: update_params.merge(format: format)
          end
          send("expect_put_update_#{format}")
        end
      end

      unless opts[:skip].include?(:update_invalid) || opts[:skip].include?(:invalid)
        it 'as authorized invalid' do
          sign_in(authorized_user_update)
          assert_difference(no_differences) do
            put update_path, params: invalid_update_params.merge(format: format)
          end
          send("expect_put_update_failed_#{format}")
        end
      end

      unless opts[:skip].include?(:update_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_update)
          put non_existing_update_path, params: update_params.merge(format: format)
          expect_not_found
        end
      end
    end
  end
end
