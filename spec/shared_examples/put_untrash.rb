# frozen_string_literal: true

RSpec.shared_examples_for 'put untrash' do |opts = {skip: []}|
  let(:r_param) { update_failed_path }

  (untrash_formats - (opts[:skip] || [])).each do |format|
    context "as #{format}" do
      unless opts[:skip].include?(:untrash_guest) || opts[:skip].include?(:guest)
        it 'as guest' do
          sign_out
          put untrash_path, params: {format: format}
          send("expect_put_untrash_guest_#{format}")
        end
      end

      unless opts[:skip].include?(:untrash_unauthorized) || opts[:skip].include?(:unauthorized)
        it 'as unauthorized' do
          subject.trash
          sign_in(unauthorized_user)
          assert_differences(no_differences) do
            put untrash_path, params: {format: format}
          end
          send("expect_put_untrash_unauthorized_#{format}")
        end
      end

      unless opts[:skip].include?(:untrash_authorized) || opts[:skip].include?(:authorized)
        it 'as authorized' do
          subject.trash
          sign_in(authorized_user)
          assert_differences(untrash_differences) do
            put untrash_path, params: {format: format}
          end
          send("expect_put_untrash_#{format}")
        end
      end

      unless opts[:skip].include?(:untrash_non_existing) || opts[:skip].include?(:non_existing)
        it 'non existing' do
          sign_in(authorized_user)
          put non_existing_untrash_path, params: {format: format}
          expect_not_found
        end
      end
    end
  end
end
