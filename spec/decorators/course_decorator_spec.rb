require 'spec_helper'

describe CourseDecorator do
  describe "#schedule" do
    context "when both meeting days and times are present" do
      it "returns the proper format for a course schedule" do
        course = Fabricate(:course, meeting_days: [0, 2, 4], start_time: "1:00PM", end_time: "1:50PM")
        expect(course.decorate.schedule).to eq("MWF 1:00PM - 1:50PM")
      end
    end

    context "when only meeting days are present" do
      it "returns only the meeting days" do
        course = Fabricate(:course, meeting_days: [0, 2, 4], start_time: nil, end_time: nil)
        expect(course.decorate.schedule).to eq("MWF")
      end
    end

    context "when only times are present" do
      it "returns only the meeting times" do
        course = Fabricate(:course, meeting_days: nil, start_time: "1:00PM", end_time: "1:50PM")
        expect(course.decorate.schedule).to eq("1:00PM - 1:50PM")
      end
    end

    context "when no meeting days or times are present" do
      it "returns none given message" do
        course = Fabricate(:course, meeting_days: nil, start_time: nil, end_time: nil)
        expect(course.decorate.schedule).to eq("No Schedule Given")
      end
    end
  end

  describe "#display_location" do
    it "displays location if one is given" do
      course = Fabricate(:course, location: "Stokes")
      expect(course.decorate.display_location).to eq("Stokes")
    end

    it "displays a no location message if no location is given" do
      course = Fabricate(:course, location: nil)
      expect(course.decorate.display_location).to eq("No Location Given")
    end
  end

  describe "#display_title" do
    it "displays title and course no. if both are given" do
      course = Fabricate(:course, title: "Philosophy", code: "PL1070")
      expect(course.decorate.display_title).to eq("Philosophy (PL1070)")
    end

    it "display only title if no course no. is given" do
      course = Fabricate(:course, title: "Philosophy", code: nil)
      expect(course.decorate.display_title).to eq("Philosophy")
    end
  end

  describe "#display_notes" do
    it "displays notes if they are present" do
      course = Fabricate(:course, notes: "hey guys")
      expect(course.decorate.display_notes).to eq("hey guys")
    end

    it "dislays message if no notes are present" do
      course = Fabricate(:course, notes: nil)
      expect(course.decorate.display_notes).to eq("No Notes Given")
    end
  end
end
