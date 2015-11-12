shared_examples "no_current_user_redirect" do
  before do
    clear_current_user
    action
  end

  it "should redirect to sign_in_path" do
    expect(response).to redirect_to sign_in_path
  end
end

shared_examples "current_user_redirect" do
  before do
    set_current_user
    action
  end

  it "should redirect to root path" do
    expect(response).to redirect_to root_path
  end
end

shared_examples "unless_instructor_redirect" do
  before do
    set_current_user
    action
  end

  it "should redirect_to root_path" do
    expect(response).to redirect_to root_path
  end
end

shared_examples "responds with js" do
  it "reponsds with js" do
    action
    expect(response.headers["Content-Type"]).to eq "text/javascript; charset=utf-8"
  end
end

shared_examples 'redirects when not enrolled' do
  context 'when a student is not enrolled in the class' do
    before do
      set_current_user
      action
    end

    it 'redirects to root_path if student is not enrolled' do
      expect(response).to redirect_to root_path
    end

    it 'flashes a warning message' do
      expect(flash[:warning]).to be_present
    end
  end
end

shared_examples "unless_instructor_owns_course_redirect" do
  context "when an instructor doesn't own a class" do
    before do
      set_current_user(instructor)
      instructor.courses_owned.delete_all
      action
    end

    it 'redirects to root_path' do
      expect(response).to redirect_to root_path
    end

    it 'flashes a warning message' do
      expect(flash[:warning]).to be_present
    end
  end

  context 'when an instructor does own a class' do
    it 'does not redirect' do
      instructor.courses_owned << course_2
      set_current_user(instructor.reload)
      action
      expect(response.status).to eq(200)
    end
  end
end
