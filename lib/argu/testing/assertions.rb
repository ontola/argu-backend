module Argu
  module Testing
    module Assertions
      def assert_not_a_member
        assert_equal true, assigns(:_not_a_member_caught)
      end

      def assert_not_a_user
        assert_equal true, assigns(:_not_a_user_caught) || assigns(:_not_logged_in_caught)
      end

      def assert_not_authorized
        assert_equal true, assigns(:_not_authorized_caught)
      end
    end
  end
end
