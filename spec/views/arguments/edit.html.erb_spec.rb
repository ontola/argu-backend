require 'spec_helper'

describe "arguments/edit" do
  before(:each) do
    @argument = FactoryGirl.create :argument
    assign(:argument, @argument)
  end

  it "renders the edit argument form" do
    render template: 'arguments/form'

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => arguments_path(@argument), :method => "post" do
      assert_select "input#argument_title", :name => "argument[title]"
      assert_select "textarea#argument_content", :name => "argument[content]"
    end
  end
end
