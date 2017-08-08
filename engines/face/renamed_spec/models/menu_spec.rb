require "spec_helper"

describe Face::Menu do
  before do
    Thread.current[:menu_items] = nil
  end

  def new_menu_item
    Face::MenuItem.new({
      name:  "Foo",
      url:   "/foo",
      regexp: /foo/
    })
  end

  describe "add and get menu items" do
    let(:menu_item) { new_menu_item }
    before { Face::Menu.new.add_item(menu_item) }
    subject { Face::Menu.new.items }

    it { should include(menu_item) }
  end
end
