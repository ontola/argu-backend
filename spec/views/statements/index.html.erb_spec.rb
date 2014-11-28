require 'spec_helper'

describe "motions/index" do
  before(:each) do
    assign(:motions, Kaminari.paginate_array([
      FactoryGirl.create(:motion),
      FactoryGirl.create(:motion)
    ]).page(1))
  end

  it "renders a list of motions" do
    render
    assert_select ".box.motion>a.title", :text => "Title".to_s, :count => 2
    assert_select ".box.motion>p", :text => "Content".to_s, :count => 2
  end
end
