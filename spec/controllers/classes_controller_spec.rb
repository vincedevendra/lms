# require 'spec_helper'
#
# describe ClassesController do
#   describe "GET index" do
#     it "assigns @classes to the current professor users's classes"
#     it_behaves_like "unless_professor_redirect"
#   end
#
#   describe "POST create" do
#     context "when validations pass" do
#       it "creates a new class when validations pass"
#       it "redirects to classes_path"
#       it "associates the class with the current professor user"
#     end
#
#     context "when validations fail" do
#       it "does not create a new class"
#       it "renders 'index' template"
#     end
#
#     it_behaves_like "unless_professor_redirect"
#   end
#
#   describe "GET edit" do
#     it "sets @class based on the params"
#     it_behaves_like "unless_professor_redirect"
#   end
#
#   describe "POST update" do
#     context "when validations pass" do
#       it "updates the class"
#       it "redirects to classes_path"
#     end
#     context "when validations fail" do
#       it "does not update the class"
#       it "renders 'edit' template"
#     end
#   end
# end
