# frozen_string_literal: true

RSpec.shared_examples_for 'put move' do |opts = {skip: []}|
  let(:r_param) { move_failed_path }
  let(:authorized_user) { staff }

  (move_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:move_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          put move_path, params: move_params.merge(format: format)
          send("expect_put_move_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:move_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          assert_difference(no_differences) do
            put move_path, params: move_params.merge(format: format)
          end
          send("expect_put_move_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:move_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user_update)
          put move_path, params: move_params.merge(format: format)
          expect_put_move
        end
      end

      unless opts[:skip].include?(:move_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_update)
          put non_existing_move_path, params: move_params.merge(format: format)
          expect_not_found
        end
      end
    end
  end
end
