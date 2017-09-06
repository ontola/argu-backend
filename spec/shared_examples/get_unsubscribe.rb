# frozen_string_literal: true

RSpec.shared_examples_for 'get unsubscribe' do
  let(:r_param) { update_failed_path }
  let(:authorized_user) { staff }

  it 'as guest' do
    sign_out
    get unsubscribe_path, params: {format: request_format}
    expect(response.code).to eq(request_format == :html ? '200' : '204')
  end

  it 'as unauthorized' do
    sign_in(unauthorized_user)
    assert_differences(no_differences) do
      get unsubscribe_path, params: {format: request_format}
    end
    expect(response.code).to eq(request_format == :html ? '200' : '204')
  end

  it 'as authorized' do
    parent_path # touch path because subject be deleted
    sign_in(authorized_user)
    assert_differences(destroy_differences) do
      get unsubscribe_path, params: {format: request_format}
    end
    expect(response.code).to eq(request_format == :html ? '200' : '204')
  end

  it 'non existing' do
    sign_in(authorized_user)
    get non_existing_unsubscribe_path, params: {format: request_format}
    expect_not_found
  end
end
