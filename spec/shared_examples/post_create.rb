# frozen_string_literal: true

RSpec.shared_examples_for 'post create' do |opts = {skip: []}|
  let(:r_param) { create_failed_path }

  (create_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:create_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_in(:guest, doorkeeper_application)
          assert_difference(create_guest_differences) do
            post create_path, params: create_params.merge(format: format)
          end
          send("expect_post_create_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:create_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          sign_in(unauthorized_user, doorkeeper_application)
          assert_difference(no_differences) do
            post create_path, params: create_params.merge(format: format)
          end
          send("expect_post_create_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:create_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          sign_in(authorized_user, doorkeeper_application)
          assert_difference(create_differences) do
            post create_path, params: create_params.merge(format: format)
          end
          send("expect_post_create_#{format}")
        end
      end

      unless opts[:skip].include?(:create_invalid) || opts[:skip].include?(:invalid)
        it 'as authorized invalid' do
          sign_in(authorized_user, doorkeeper_application)
          assert_difference(no_differences) do
            post create_path, params: invalid_create_params.merge(format: format)
          end
          send("expect_post_create_failed_#{format}")
        end
      end

      unless opts[:skip].include?(:create_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing parent' do
          sign_in(authorized_user, doorkeeper_application)
          assert_difference(no_differences) do
            post non_existing_create_path, params: non_existing_create_params.merge(format: format)
          end
          expect_not_found
        end
      end
    end
  end
end
