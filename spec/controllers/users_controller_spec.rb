require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets a new user variable" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it_behaves_like "current_user_redirect" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    context "when validations pass" do
      before { post :create, user: Fabricate.attributes_for(:user) }

      it "saves the new user" do
        expect(User.count).to eq(1)
      end

      it "assigns professor value of false" do
        expect(User.first.professor?).to be_falsy
      end

      it "redirects to the sign in page" do
        expect(response).to redirect_to sign_in_path
      end
    end

    context "when validations fail" do
      before { post :create, user: Fabricate.attributes_for(:user, email: nil) }

      it "does not save the user" do
        expect(User.count).to eq(0)
      end

      it "renders the new template" do
        expect(response).to render_template 'new'
      end
    end

    it_behaves_like "current_user_redirect" do
      let(:action) { post :create, user: Fabricate.attributes_for(:user) }
    end
  end

  describe "POST create_professor" do
    before { ENV["professor_key"] = '12345' }

    context "when validations pass" do
      context "when key is valid" do
        before do 
          post :create_professor, user: Fabricate.attributes_for(:user), key: '12345'
        end

        it "creates a new user" do
          expect(User.count).to eq(1)
        end

        it "assigns the user as a professor" do
          expect(User.first).to be_professor
        end

        it "sets a success message" do
          expect(flash[:success]).to be_present
        end

        it "redirects to sign_in path" do
          expect(response).to redirect_to sign_in_path
        end
      end

      context "when key is invalid" do
        before do 
          post :create_professor, user: Fabricate.attributes_for(:user), key: '12346'
        end

        it "does not create a user" do
          expect(User.count).to eq(0)
        end

        it "sets a danger message" do
          expect(flash[:danger]).to be_present
        end

        it "renders 'new_professor'" do
          expect(response).to render_template 'new_professor'
        end
      end
    end

    context "when validations fail" do
      before do 
        post :create_professor, user: Fabricate.attributes_for(:user, email: ''), key: '12345'
      end

      it "does not create a user" do
        expect(User.count).to eq(0)
      end

      it "renders 'new_professor" do
        expect(response).to render_template 'new_professor'
      end  
    end

    it_behaves_like "current_user_redirect" do
      let(:action) { post :create_professor, user: Fabricate.attributes_for(:user), key: '12345' }
    end
  end
end