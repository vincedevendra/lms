class BoxViewWrapper
  TOKEN = ENV['BOX_VIEW_API_KEY']
  UPLOAD_URL = 'https://view-api.box.com/1/documents'
  VIEW_URL = 'https://view-api.box.com/1/sessions'

  def self.upload(file_url, file_name)
    values = { "url" => file_url, "name" => file_name }.to_json

    RestClient.post(UPLOAD_URL, values, headers) do |response, request, result|
      result.class == Net::HTTPAccepted ? JSON[response] : :error
    end
  end

  def self.view_url(box_view_id)
    values = { "document_id" => box_view_id }.to_json

    RestClient.post(VIEW_URL, values, headers) do |response, request, result|
      unless document_ready?(response)
        try_again(response, box_view_id)
      else
        JSON[response]['urls']['view']
      end
    end
  end

  private

  def self.headers
    { "Content-Type" => 'application/json', 
      "Authorization" => "Token #{TOKEN}" }
  end

  def self.document_ready?(response)
    response.code != 202
  end

  def self.try_again(response, box_view_id)
    sleep(response.headers[:retry_after].to_i)
    view_url(box_view_id)
  end
end
