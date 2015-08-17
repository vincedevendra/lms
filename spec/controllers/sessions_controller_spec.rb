require 'spec_helper'

describe SessionsController do
  describe "POST create" do
    context "when user info is authenticated" do
      let(:pete) { Fabricate(:user) }
      before { post :create, email: pete.email, password: 'password' }
      
      it "logs in authenticated user" do
        expect(session[:user_id]).to eq(pete.id)
      end

      it "redirects authenticated user to root_path" do
        expect(response).to redirect_to root_path
      end
    end
    
    context "when user info is unauthenticated" do  
      let(:pete) { Fabricate(:user) }
      before { post :create, email: pete.email, password: 'skadoo' }
      
      it "does not log in" do
        expect(session[:user_id]).to be_nil
      end

      it "sets a danger message" do
        expect(flash[:danger]).to be_present
      end

      it "renders 'new' for unauthenticated user" do
        expect(response).to render_template 'new'
      end
    end

    it_behaves_like "current_user_redirect" do
      let(:pete) { Fabricate(:user) }
      let(:action) { post :create, email: pete.email, password: 'password' }
    end
  end
end