require 'spec_helper'

describe SubmissionBoxViewUploader do
  describe '#upload_to_box_view' do
    it "calls BoxViewWrapper's upload method" do
      submission = double(submission_url: 'http://foo@bar.net', submission: double('file', file: double('file_name', filename: 'foo.docx'))) 
      submission_url = submission.submission_url
      file_name = submission.submission.file.filename
      uploader = SubmissionBoxViewUploader.new(submission)
      allow(BoxViewWrapper).to receive(:upload)

      uploader.upload_to_box_view

      expect(BoxViewWrapper).to have_received(:upload).with(submission_url, file_name)
    end

    it "saves the upload response to @api_response" do
      submission = double(submission_url: 'http://foo@bar.net', submission: double('file', file: double('file_name', filename: 'foo.docx'))) 
      uploader = SubmissionBoxViewUploader.new(submission)
      allow(BoxViewWrapper).to receive(:upload) { 'foo' }

      uploader.upload_to_box_view

      expect(uploader.api_response).to eq('foo')
    end
  end

  describe '#success?' do
    it "returns false if the @api_response is :error" do
      submission = double(submission_url: 'http://foo@bar.net', submission: double('file', file: double('file_name', filename: 'foo.docx'))) 
      uploader = SubmissionBoxViewUploader.new(submission)
      allow(uploader).to receive(:api_response) { :error }

      expect(uploader.success?).to eq(false)
    end

    it "returns true if the @api_response is not :error" do
      submission = double
      uploader = SubmissionBoxViewUploader.new(submission)
      allow(uploader).to receive(:api_response) { 'foo' }
      
      expect(uploader.success?).to eq(true)
    end
  end

  describe '#box_view_id' do
    it "returns the id from the api_response" do
      submission = double
      uploader = SubmissionBoxViewUploader.new(submission)
      allow(uploader).to receive(:api_response) { {'id' => '123'} }

      expect(uploader.box_view_id).to eq('123')
    end

    it "returns nil if the api_response doesn't contain an id" do
      submission = double
      uploader = SubmissionBoxViewUploader.new(submission)
      allow(uploader).to receive(:api_response) { {'nope' => '123'} }

      expect(uploader.box_view_id).to be_nil
    end
  end
end
