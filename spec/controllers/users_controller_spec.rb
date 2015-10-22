require 'spec_helper'

describe UsersController do
  describe "GET new" do
    it "sets a new user variable" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    context 'when the params invite token is present' do
      let(:invitation) { Fabricate(:invitation) }

      it 'sets @invitation_token to the token on the invitation' do
        get :new, token: invitation.token
        expect(assigns(:invitation_token)).to eq(invitation.token)
      end

      it 'sets @invitation_email to the email on the invitation' do
        get :new, token: invitation.token
        expect(assigns(:invitation_email)).to eq(invitation.email)
      end
    end

    it_behaves_like "current_user_redirect" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    context "when validations pass" do
      context "when no invitation is present" do
        before { post :create, user: Fabricate.attributes_for(:user) }

        it "saves the new user" do
          expect(User.count).to eq(1)
        end

        it "assigns instructor value of false" do
          expect(User.first).not_to be_instructor
        end

        it "redirects to the sign in page" do
          expect(response).to redirect_to sign_in_path
        end
      end

      context "when an invitation is present" do
        let(:invitation) { Fabricate(:invitation) }

        before do
           post :create, user: Fabricate.attributes_for(:user).merge(token: invitation.token)
        end

        it 'creates an enrollment' do
          expect(Enrollment.count).to eq(1)
        end

        it 'sets a flash info message' do
          expect(flash[:info]).to be_present
        end
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
end
