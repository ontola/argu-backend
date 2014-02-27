require 'spec_helper'

describe "arguments/edit" do
  before(:each) do
    @argument = assign(:argument, stub_model(Argument,
      :title => "MyString",
      :content => "MyString",
      :type => 1
    ))
  end

  it "renders the edit argument form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => arguments_path(@argument), :method => "post" do
      assert_select "input#argument_title", :name => "argument[title]"
      assert_select "input#argument_content", :name => "argument[content]"
      assert_select "input#argument_type", :name => "argument[type]"
    end
  end
end
