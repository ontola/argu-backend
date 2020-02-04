# frozen_string_literal: true

RSpec.shared_examples_for 'post move' do |opts = {skip: []}|
  let(:r_param) { move_failed_path }
  let(:authorized_user) { staff }

  (move_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:move_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(guest_user)
          post move_path, params: move_params, headers: request_headers(format)
          send("expect_post_move_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:move_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          assert_difference(no_differences) do
            post move_path, params: move_params, headers: request_headers(format)
          end
          send("expect_post_move_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:move_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_update)
          post move_path, params: move_params, headers: request_headers(format)
          expect_post_move
        end
      end

      unless opts[:skip].include?(:move_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_update)
          post non_existing_move_path, params: move_params, headers: request_headers(format)
          expect_not_found
        end
      end
    end
  end
end
