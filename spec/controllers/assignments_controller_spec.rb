require 'spec_helper'

describe AssignmentsController do
  describe "GET index" do
    before { set_current_user }
    let!(:assignment_1) { Fabricate(:assignment, due_date: 3.days.ago) }
    let!(:assignment_2) { Fabricate(:assignment, due_date: 1.day.from_now) }

    it "displays all the existing assignments" do
      get :index
      expect(assigns(:assignments)).to match_array([assignment_1, assignment_2])
    end

    it "orders assignments by due date" do
      get :index
      expect(assigns(:assignments)).to eq([assignment_2, assignment_1])
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :index }
    end
  end
  
  describe "GET new" do
    before { set_professor_user }

    it "sets a new assignment object" do
      get :new
      expect(assigns(:assignment)).to be_a_new(Assignment)
    end

    it_behaves_like "unless_professor_redirect" do
      let(:action) { get :new }
    end
  end

  describe "POST create" do
    before { set_professor_user }

    context "when the post passes validations" do
      before { post :create, assignment: Fabricate.attributes_for(:assignment) }

      it "creates a new assignment object" do
        expect(Assignment.count).to eq(1)
      end

      it "sets a success message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to the root path" do
        expect(response).to redirect_to root_path
      end
    end

    context "When the post fails validations" do
      before { post :create, assignment: Fabricate.attributes_for(:assignment, title: nil) }
      it "does not create a new assignment object" do
        expect(Assignment.count).to eq(0)
      end

      it "renders the new template" do
        expect(response).to render_template 'new'
      end
    end

    it_behaves_like "unless_professor_redirect" do
      let(:action) { post :create, assignment: Fabricate.attributes_for(:assignment) }
    end
  end

  describe "POST edit" do
    before { set_professor_user }
    it "uses params to set an existing assignment object" do
      essay = Fabricate(:assignment)
      get :edit, id: essay.id
      expect(assigns(:assignment).title).to eq(essay.title)
    end

    it_behaves_like "unless_professor_redirect" do 
      essay = Fabricate(:assignment)
      let(:action) { get :edit, id: essay.id }
    end
  end

  describe "PATCH update" do
    before { set_professor_user }

    context "when validations pass" do 
      let(:essay) { Fabricate(:assignment, title: "foo") }
      before do
        put :update, id: essay.id, assignment: { title: essay.title, 
                                     description: essay.description, 
                                     due_date: "10/10/2017", 
                                     point_value: 3}
      end

      it "updates the object when validations pass" do
        expect(essay.reload.point_value).to eq(3)
      end

      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to root_path" do
        expect(response).to redirect_to root_path
      end
    end

    context "when validations fail" do
      let(:essay) { Fabricate(:assignment, title: "foo") }
      before { patch :update, id: essay.id, assignment: { title: "bar", point_value: nil } }

      it "does not update the object" do
        expect(essay.reload.title).to eq("foo")
      end  
    end

    it_behaves_like "unless_professor_redirect" do
      essay = Fabricate(:assignment)
      let(:action) { patch :update, id: essay.id, assignment: Fabricate.attributes_for(:assignment) }
    end
  end

  describe "DELETE destroy" do
    let(:essay) { Fabricate(:assignment) }

    before do 
      set_professor_user    
    end

    it "deletes the assignment" do
      delete :destroy, id: essay.id
      expect(Assignment.count).to eq(0)
    end

    it "redirects to root_path" do
      delete :destroy, id: essay.id
      expect(response).to redirect_to root_path
    end

    it_behaves_like "unless_professor_redirect" do
      let(:action) { delete :destroy, id: essay.id }
    end
  end
end