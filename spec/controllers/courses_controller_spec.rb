require 'spec_helper'

describe CoursesController do
  describe "GET index" do
    context "when the current user is an instructor" do
      let(:instructor) { Fabricate(:user, instructor: true) }

      before { set_current_user(instructor) }


      it "assigns @courses to the current instructor users's courses" do
        course_1 = Fabricate(:course, instructor: instructor)
        course_2 = Fabricate(:course, instructor: instructor)
        course_3 = Fabricate(:course)
        get :index
        expect(assigns(:courses)).to match_array([course_1, course_2])
      end

      it "orders instructor's classes by most recently created" do
        course_1 = Fabricate(:course, instructor: instructor, created_at: 2.days.ago)
        course_2 = Fabricate(:course, instructor: instructor)
        get :index
        expect(assigns(:courses)).to eq([course_2, course_1])
      end
    end

    context "when the current user is a student" do
      let(:student) { Fabricate(:user) }
      let!(:course_1) { Fabricate(:course, title: "Biology") }
      let!(:course_2) { Fabricate(:course, title: "Algebra") }
      let!(:course_3) { Fabricate(:course) }

      before do
        set_current_user(student)
        student.courses << course_1 << course_2
        get :index
      end

      it "assigns courses to the current student's courses" do
        expect(assigns(:courses)).to match_array([course_1, course_2])
      end

      it "orders students courses according to title" do
        expect(assigns(:courses)).to eq([course_2, course_1])
      end
    end
  end

  describe "GET new" do
    before { set_instructor_user }

    it "sets @course to a new course" do
      xhr :get, :new, format: :js
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe "POST create" do
    it_behaves_like "unless_instructor_redirect" do
      let(:action) { xhr :post, :create, course: Fabricate.attributes_for(:course) }
    end

    context "when validations pass" do
      let(:albert) { Fabricate(:instructor) }

      before { set_current_user(albert) }

      it "creates a new course" do
        xhr :post, :create, course: Fabricate.attributes_for(:course)
        expect(Course.count).to eq(1)
      end

      it "associates the class with the current instructor user" do
        xhr :post, :create, course: Fabricate.attributes_for(:course)
        expect(Course.last.instructor).to eq(albert)
      end

      it "sets a flash success message" do
        xhr :post, :create, course: Fabricate.attributes_for(:course)
        expect(flash[:success]).to be_present
      end

      it_behaves_like "responds with js" do
        let(:action) { xhr :post, :create, course: Fabricate.attributes_for(:course)}
      end
    end

    context "when validations fail" do
      let(:albert) { Fabricate(:user) }

      before do
        set_current_user(albert)
        xhr :post, :create, Fabricate.attributes_for(:course, title: nil)
      end

      it "does not create a new course" do
        expect(Course.count).to eq(0)
      end
    end

    it_behaves_like "unless_instructor_redirect" do
      let(:action) { xhr :post, :create, course: Fabricate.attributes_for(:course) }
    end
  end

   describe "GET edit" do
     before { set_instructor_user }

     it "sets @course based on the params" do
       course = Fabricate(:course)
       xhr :get, :edit, id: course.id, format: :js
       expect(assigns(:course)).to eq(course)
     end

     it_behaves_like "unless_instructor_redirect" do
       let(:action) { xhr :get, :edit, id: 1 }
     end
   end

  describe "POST update" do
    let(:instructor) { Fabricate(:instructor) }
    before { set_current_user(instructor) }

    it_behaves_like "unless_instructor_redirect" do
      let(:action) { xhr :patch, :update, id: 123, course: Fabricate.attributes_for(:course) }
    end

    context "when the current user owns the course" do
      context "when validations pass" do
        let(:course) { Fabricate(:course, title: "Foo 101", user_id: instructor.id) }

        it "updates the course" do
          xhr :patch, :update, id: course.id, course: { title: "Bar 102"}
          expect(course.reload.title).to eq("Bar 102")
        end

        it "flashes a success message" do
          xhr :patch, :update, id: course.id, course: { title: "Bar 102"}
          expect(flash[:success]).to be_present
        end

        it_behaves_like "responds with js" do
          let(:action) { xhr :patch, :update, id: course.id, course: { title: "Bar 102"} }
        end
      end

      context "when validations fail" do
        let(:course) { Fabricate(:course, title: "Foo 101", location: "Earth", user_id: instructor.id)}

        it "does not update the class" do
          xhr :patch, :update, id: course.id, course: { title: nil, location: "Mars"}
          expect(course.reload.location).to eq("Earth")
        end

        it "does not flash success message" do
          xhr :patch, :update, id: course.id, course: { title: nil, location: "Mars"}
          expect(flash[:success]).to be_nil
        end
      end
    end

    context "when the current user doesn't own the course" do
      it "does not update the course" do
        course = Fabricate(:course, title: "Foo 101")
        xhr :patch, :update, id: course.id, course: { title: "Bar 102"}
        expect(course.reload.title).to eq("Foo 101")
      end
    end
  end

  describe "DELETE destroy" do
    let(:instructor) { Fabricate(:instructor) }
    before { set_current_user(instructor) }

    context "when the current user owns the course" do
      let(:course) { Fabricate(:course, instructor: instructor) }
      before { delete :destroy, id: course.id }

      it "deletes the course" do
        expect(Course.count).to eq(0)
      end

      it "redirects to index" do
        expect(response).to redirect_to courses_path
      end
    end

    context "when the current user does not own the course" do
      let(:course) { Fabricate(:course) }
      before { delete :destroy, id: course.id }

      it "does not delete the coures" do
        expect(Course.count).to eq(1)
      end

      it "flashes a danger message" do
        expect(flash[:danger]).to be_present
      end

      it "redirect to the index path" do
        expect(response).to redirect_to courses_path
      end
    end
  end
end
