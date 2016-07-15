# frozen_string_literal: true

# Shared tests for all the models
module ModelTestBase
  def test_should_respond_to_default_methods
    assert subject.respond_to? :display_name
    assert subject.respond_to? :identifier
    assert subject.respond_to? :class_name
  end
end
