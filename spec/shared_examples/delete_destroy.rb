# frozen_string_literal: true

RSpec.shared_examples_for 'delete destroy' do |opts = {skip: []}|
  let(:r_param) { update_failed_path }
  let(:authorized_user) { staff }

  unless opts[:skip].include?(:destroy_guest) || opts[:skip].include?(:guest)
    it 'as guest' do
      sign_out
      delete destroy_path, params: {format: request_format}
      send("expect_delete_destroy_guest_#{request_format}")
    end
  end

  unless opts[:skip].include?(:destroy_unauthorized) || opts[:skip].include?(:unauthorized)
    it 'as unauthorized' do
      sign_in(unauthorized_user)
      assert_differences(no_differences) do
        delete destroy_path, params: {format: request_format}
      end
      send("expect_delete_destroy_unauthorized_#{request_format}")
    end
  end

  unless opts[:skip].include?(:destroy_authorized) || opts[:skip].include?(:authorized)
    it 'as authorized' do
      parent_path # touch path because subject be deleted
      sign_in(authorized_user_update)
      assert_differences(destroy_differences) do
        delete destroy_path, params: destroy_params.merge(format: request_format)
      end
      send("expect_delete_destroy_#{request_format}")
    end
  end

  unless opts[:skip].include?(:destroy_non_existing) || opts[:skip].include?(:non_existing)
    it 'non existing' do
      sign_in(authorized_user_update)
      delete non_existing_destroy_path, params: {format: request_format}
      expect_not_found
    end
  end
end
