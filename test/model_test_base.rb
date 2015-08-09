
# Shared tests for all the models
module ModelTestBase

  def test_should_respond_to_default_methods
    subject.respond_to? :display_name
    subject.respond_to? :identifier
    subject.respond_to? :class_name
  end
end
