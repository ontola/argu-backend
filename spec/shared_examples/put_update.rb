# frozen_string_literal: true

RSpec.shared_examples_for 'put update' do |opts = {skip: []}|
  let(:r_param) { update_failed_path }

  unless opts[:skip].include?(:new_guest) || opts[:skip].include?(:guest)
    it 'as guest' do
      sign_out
      put update_path, params: update_params.merge(format: request_format)
      send("expect_put_update_guest_#{request_format}")
    end
  end

  unless opts[:skip].include?(:update_unauthorized) || opts[:skip].include?(:unauthorized)
    it 'as unauthorized' do
      sign_in(unauthorized_user)
      assert_differences(no_differences) do
        put update_path, params: update_params.merge(format: request_format)
      end
      send("expect_put_update_unauthorized_#{request_format}")
    end
  end

  unless opts[:skip].include?(:update_authorized) || opts[:skip].include?(:authorized)
    it 'as authorized' do
      sign_in(authorized_user_update)
      assert_differences(update_differences) do
        put update_path, params: update_params.merge(format: request_format)
      end
      send("expect_put_update_#{request_format}")
    end
  end

  unless opts[:skip].include?(:update_invalid) || opts[:skip].include?(:invalid)
    it 'as authorized invalid' do
      sign_in(authorized_user_update)
      assert_differences(no_differences) do
        put update_path, params: invalid_update_params.merge(format: request_format)
      end
      send("expect_put_update_failed_#{request_format}")
    end
  end

  unless opts[:skip].include?(:update_non_existing) || opts[:skip].include?(:non_existing)
    it 'non existing' do
      sign_in(authorized_user_update)
      put non_existing_update_path, params: update_params.merge(format: request_format)
      expect_not_found
    end
  end
end
