require 'spec_helper'

describe "statements/index" do
  before(:each) do
    assign(:statements, Kaminari.paginate_array([
      FactoryGirl.create(:statement),
      FactoryGirl.create(:statement)
    ]).page(1))
  end

  it "renders a list of statements" do
    render
    assert_select ".box.statement>a.title", :text => "Title".to_s, :count => 2
    assert_select ".box.statement>p", :text => "Content".to_s, :count => 2
  end
end
