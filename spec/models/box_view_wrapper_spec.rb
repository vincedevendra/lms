require 'spec_helper'

describe BoxViewWrapper, vcr: true do
   describe '#upload' do
    it "returns an error status when a bad request is made" do
      subject = BoxViewWrapper.upload('foo', 'bar')
      expect(subject).to eq(:error)
    end

    it 'should return json with the proper file name' do
      public_doc_url =  "https://s3.amazonaws.com/vince-gradebook/sample.docx"
      name = 'sample_file'
      subject = BoxViewWrapper.upload(public_doc_url, name)
      expect(subject['name']).to eq('sample_file')
    end
  end

  describe "#view_url", vcr: true do
    it "returns a view url for iframe if document has a valid box view id" do
      public_doc_url =  "https://s3.amazonaws.com/vince-gradebook/sample.docx"
      name = 'sample_file'
      response = BoxViewWrapper.upload(public_doc_url, name)
      box_view_id = response['id']
      
      expect(BoxViewWrapper.view_url(box_view_id)).to include('https://')
    end
  end
end
