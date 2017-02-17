require 'spec_helper'

describe AssignmentsController do
  describe "GET index" do
    let(:course) { Fabricate(:course) }
    let!(:assignment_1) { Fabricate(:assignment, due_date: 3.days.ago, course: course) }
    let!(:assignment_2) { Fabricate(:assignment, due_date: 1.day.from_now, course: course) }

    before do
      set_current_user
      get :index, course_id: course.id
    end

    it "sets the course from the params" do
      expect(assigns(:course)).to eq(course)
    end

    it_behaves_like "no_current_user_redirect" do
      let(:action) { get :index, course_id: course.id }
    end
  end

  describe "GET new" do
    before { set_instructor_user }
    let(:course) { Fabricate(:course) }

    it "sets a new assignment object" do
      xhr :get, :new, course_id: course.id
      expect(assigns(:assignment)).to be_a_new(Assignment)
    end

    it "sets the course from the params" do
      xhr :get, :index, course_id: course.id
      expect(assigns(:course)).to eq(course)
    end

    it_behaves_like "unless_instructor_redirect" do
      let(:action) { get :new, course_id: course.id }
    end
  end

  describe "POST create" do
    let(:course) { Fabricate(:course) }
    before { set_instructor_user }

    context "when the post passes validations" do
      it "creates a new assignment object" do
        xhr :post, :create, assignment: Fabricate.attributes_for(:assignment), course_id: course.id
        expect(Assignment.count).to eq(1)
      end

      it 'sets submission_required to true when chechbox is checked' do
        xhr :post, :create, assignment: Fabricate.attributes_for(:assignment, submission_required: 1), course_id: course.id
        expect(Assignment.first).to be_submission_required
      end

      it 'sets submission_required to false when checkbox is not checked' do
        xhr :post, :create, assignment: Fabricate.attributes_for(:assignment, submission_required: 0), course_id: course.id
        expect(Assignment.first).not_to be_submission_required
      end

      it "associates the assignment with the current course" do
        xhr :post, :create, assignment: Fabricate.attributes_for(:assignment), course_id: course.id
        expect(Assignment.last.course).to eq(course)
      end

      it "sets a success message" do
        xhr :post, :create, assignment: Fabricate.attributes_for(:assignment), course_id: course.id
        expect(flash[:success]).to be_present
      end

      it "renders the create js template" do
        xhr :post, :create, assignment: Fabricate.attributes_for(:assignment), course_id: course.id
        expect(response).to render_template "assignments/create"
      end
    end

    context "When the post fails validations" do
      before { xhr :post, :create, assignment: Fabricate.attributes_for(:assignment, title: nil), course_id: course.id }

      it "does not create a new assignment object" do
        expect(Assignment.count).to eq(0)
      end
    end

    it_behaves_like "unless_instructor_redirect" do
      let(:action) { xhr :post, :create, assignment: Fabricate.attributes_for(:assignment), course_id: course.id }
    end
  end

  describe "POST edit" do
    before { set_instructor_user }
    let(:course) { Fabricate(:course) }
    let(:essay) { Fabricate(:assignment, course: course) }

    it "uses params to set an existing assignment object" do
      essay = Fabricate(:assignment)
      xhr :get, :edit, id: essay.id, course_id: course.id
      expect(assigns(:assignment).title).to eq(essay.title)
    end

    it "sets the course from the params" do
      xhr :get, :edit, id: essay.id, course_id: course.id
      expect(assigns(:course)).to eq(course)
    end

    it "renders the edit js template" do
      xhr :get, :edit, id: essay.id, course_id: course.id
      expect(response).to render_template("assignments/edit")
    end

    it_behaves_like "unless_instructor_redirect" do
      essay = Fabricate(:assignment)
      let(:action) { xhr :get, :edit, id: essay.id, course_id: course.id }
    end
  end

  describe "PATCH update" do
    before { set_instructor_user }
    let(:course) { Fabricate(:course) }

    context "when validations pass" do
      let(:essay) { Fabricate(:assignment, title: "foo") }

      before do
        xhr :patch, :update, id: essay.id, course_id: course.id,
                     assignment: { title: essay.title,
                                   description: essay.description,
                                   due_date: "10/10/2017",
                                   point_value: 3}
      end

      it "updates the object when validations pass" do
        expect(essay.reload.point_value).to eq(3)
      end

      it "sets the course from the params" do
        xhr :patch, :update, id: essay.id, course_id: course.id, assignment: Fabricate.attributes_for(:assignment)
        expect(assigns(:course)).to eq(course)
      end

      it "flashes a success message" do
        expect(flash[:success]).to be_present
      end

      it "renders js template" do
        expect(response).to render_template "assignments/update"
      end
    end

    context "when validations fail" do
      let(:essay) { Fabricate(:assignment, title: "foo") }
      let(:course) { Fabricate(:course) }
      before { xhr :patch, :update, id: essay.id, assignment: { title: "bar", point_value: nil }, course_id: course.id }

      it "does not update the object" do
        expect(essay.reload.title).to eq("foo")
      end
    end

    it_behaves_like "unless_instructor_redirect" do
      essay = Fabricate(:assignment)
      let(:action) { xhr :patch, :update, id: essay.id, assignment: Fabricate.attributes_for(:assignment), course_id: course.id }
    end
  end

  describe "DELETE destroy" do
    let(:essay) { Fabricate(:assignment) }
    let(:course) { Fabricate(:course) }

    it "deletes the assignment" do
      set_instructor_user
      delete :destroy, id: essay.id, course_id: course.id
      expect(Assignment.count).to eq(0)
    end

    it "flashes a message" do
      set_instructor_user
      delete :destroy, id: essay.id, course_id: course.id
      expect(flash[:danger]).to be_present
    end

    it "redirects to root_path" do
      set_instructor_user
      delete :destroy, id: essay.id, course_id: course.id
      expect(response).to redirect_to root_path
    end

    it_behaves_like "unless_instructor_redirect" do
      let(:action) { delete :destroy, id: essay.id, course_id: course.id }
    end
  end
end
