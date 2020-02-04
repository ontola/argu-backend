# frozen_string_literal: true

module Argu
  module TestHelpers
    module DefaultPolicyTests
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def model_name
          name.gsub('PolicyTest', '').underscore
        end

        def generate_crud_tests
          %i[create show update destroy].each do |method|
            define_method "test_#{method}_#{model_name}" do
              direct_child if method == :destroy
              test_policy(subject, method, send("#{method}_results"))
            end
          end
        end

        def generate_edgeable_tests # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
          generate_crud_tests

          %i[trash follow log invite move convert feed].each do |method|
            define_method "test_#{method}_#{model_name}" do
              test_policy(subject, method, send("#{method}_results"))
            end
          end

          define_method "test_show_#{model_name}_in_unpublished_forum" do
            test_policy(unpublished_subject, :show, show_unpublished_results) if unpublished_subject
          end

          define_method "test_show_#{model_name}_in_expired_forum" do
            test_policy(expired_subject, :show, show_expired_results) if expired_subject
          end

          define_method "test_show_#{model_name}_in_trashed_forum" do
            test_policy(expired_subject, :show, show_trashed_results) if trashed_subject
          end

          define_method "test_create_#{model_name}_in_expired_forum" do
            test_policy(expired_subject, :create, create_expired_results) if expired_subject
          end

          define_method "test_create_#{model_name}_in_trashed_forum" do
            test_policy(trashed_subject, :create, create_trashed_results) if trashed_subject
          end
          define_method "test_destroy_#{model_name}_with_children" do
            direct_child&.update(publisher: create(:user))
            test_policy(subject, :destroy, destroy_with_children_results) if direct_child
          end
        end
      end
    end
  end
end
