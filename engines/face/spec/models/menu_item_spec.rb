require "spec_helper"

describe Face::MenuItem do
  let(:attributes) do
    { name:   "Users",
      url:    "/users",
      regexp: /users/ }
  end
  subject(:item) { Face::MenuItem.new(attributes) }

  its(:name) { should == "Users" }
  its(:url) { should == "/users" }

  describe "#active?" do
    context "with not matched path" do
      it "is false" do
        expect(item.active?("/projects")).to be_false
      end
    end

    context "with matched path" do
      it "is true" do
        expect(item.active?("/users?foo=bar")).to be_true
      end
    end
  end
end
