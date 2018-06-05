module Pack
  require "spec_helper"
  describe Admin::PackagesController, type: :controller do
    routes { Pack::Engine.routes }
    before(:each) do
      Group.default!
    end
    describe "#index" do
      it "shows packages" do
      admin = create_admin
      login_user(admin)
      package = create(:package)
      get :index
      expect(assigns(:records)).to eq( [package] )
      expect(response).to render_template("index")
      end
    end
  end
end
