require 'spec_helper'

describe BoxViewWrapper, vcr: true do
  let(:public_doc_url){ "https://s3.amazonaws.com/vince-gradebook/sample.docx" }
  let(:name) { 'sample_file' }

   describe '#upload' do
    subject{ BoxViewWrapper.upload(public_doc_url, name) }

    it 'should return json with the proper file name' do
      expect(subject['name']).to eq('sample_file')
    end
  end
end
