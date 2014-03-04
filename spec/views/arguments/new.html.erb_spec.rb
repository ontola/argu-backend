require 'spec_helper'

describe "arguments/new" do
  before(:each) do
    @argument = FactoryGirl.create :argument
    assign(:argument, @argument)
  end

  it "renders new argument form" do
    render template: 'arguments/form'

    # Should be empty since it's a new object
    assert_select "form", :action => arguments_path, :method => "post" do
      assert_select "input#argument_title", name: 'argument[title]'
      assert_select "textarea#argument_content", name: 'argument[content]'
    end
  end

  it "has the statement title in the header" do
    render template: 'arguments/form'
    assert_select 'a.title.statement.top', @argument.statement.title
  end

end
