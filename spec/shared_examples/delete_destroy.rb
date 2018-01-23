# frozen_string_literal: true

RSpec.shared_examples_for 'delete destroy' do |opts = {skip: []}|
  let(:r_param) { destroy_failed_path }

  (destroy_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:destroy_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          delete destroy_path, params: {format: format}
          send("expect_delete_destroy_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:destroy_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user)
          assert_differences(no_differences) do
            delete destroy_path, params: {format: format}
          end
          send("expect_delete_destroy_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:destroy_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          parent_path # touch path because subject be deleted
          sign_in(authorized_user_destroy)
          assert_differences(destroy_differences) do
            delete destroy_path, params: destroy_params.merge(format: format)
          end
          send("expect_delete_destroy_#{format}")
        end
      end

      unless opts[:skip].include?(:destroy_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user_destroy)
          delete non_existing_destroy_path, params: {format: format}
          expect_not_found
        end
      end
    end
  end
end
