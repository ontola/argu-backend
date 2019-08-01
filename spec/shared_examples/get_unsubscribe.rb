# frozen_string_literal: true

RSpec.shared_examples_for 'get unsubscribe' do
  let(:r_param) { update_failed_path }
  let(:authorized_user) { staff }

  unsubscribe_formats.each do |format|
    context "as #{format}" do
      it 'as guest' do
        sign_in(:guest, doorkeeper_application(format))
        get unsubscribe_path, headers: request_headers(format)
        expect(response.code).to eq(format == :json_api ? '204' : '200')
      end

      it 'as unauthorized' do
        sign_in(unauthorized_user, doorkeeper_application(format))
        assert_difference(no_differences) do
          get unsubscribe_path, headers: request_headers(format)
        end
        expect(response.code).to eq(format == :json_api ? '204' : '200')
      end

      it 'as authorized' do
        parent_path # touch path because subject be deleted
        sign_in(authorized_user, doorkeeper_application(format))
        assert_difference(destroy_differences) do
          get unsubscribe_path, headers: request_headers(format)
        end
        expect(response.code).to eq(format == :json_api ? '204' : '200')
      end

      it 'non existing' do
        sign_in(authorized_user, doorkeeper_application(format))
        get non_existing_unsubscribe_path, headers: request_headers(format)
        expect_not_found
      end
    end
  end
end
