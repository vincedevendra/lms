require 'spec_helper'

describe InstructorsController do
  describe "POST create" do
    before { ENV["instructor_key"] = '12345' }

    context "when validations pass" do
      context "when key is valid" do
        before do
          post :create, user: Fabricate.attributes_for(:user), key: '12345'
        end

        it "creates a new user" do
          expect(User.count).to eq(1)
        end

        it "assigns the user as a instructor" do
          expect(User.first).to be_instructor
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
          post :create, user: Fabricate.attributes_for(:user), key: '12346'
        end

        it "does not create a user" do
          expect(User.count).to eq(0)
        end

        it "sets a danger message" do
          expect(flash[:danger]).to be_present
        end

        it "renders 'users/new'" do
          expect(response).to render_template 'instructors/new'
        end
      end
    end

    context "when validations fail" do
      before do
        post :create, user: Fabricate.attributes_for(:user, email: ''), key: '12345'
      end

      it "does not create a user" do
        expect(User.count).to eq(0)
      end

      it "renders 'new" do
        expect(response).to render_template 'instructors/new'
      end
    end

    it_behaves_like "current_user_redirect" do
      let(:action) { post :create, user: Fabricate.attributes_for(:user), key: '12345' }
    end
  end
end
