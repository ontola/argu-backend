require 'spec_helper'

describe "arguments/new" do
  before(:each) do
    assign(:argument, stub_model(Argument,
      :title => "MyString",
      :content => "MyString",
      :type => 1
    ).as_new_record)
  end

  it "renders new argument form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => arguments_path, :method => "post" do
      assert_select "input#argument_title", :name => "argument[title]"
      assert_select "input#argument_content", :name => "argument[content]"
      assert_select "input#argument_type", :name => "argument[type]"
    end
  end
end
