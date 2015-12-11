class BoxViewWrapper
  TOKEN = ENV['BOX_VIEW_API_KEY']
  UPLOAD_URL = 'https://view-api.box.com/1/documents'
  VIEW_URL = "https://view-api.box.com/1/sessions"

  def self.upload(file_url)
    values = {
      "url" => file_url,
    }.to_json

    headers = {
      "Content-Type" => 'application/json',
      "Authorization" => "Token #{TOKEN}"
    }

    JSON[RestClient.post(UPLOAD_URL, values, headers)]
  end

  def self.check_status(box_view_id)
    headers = { :authorization => "Token #{TOKEN}" }

    JSON[RestClient.get(EMBED_URL + "/#{box_view_id}"), headers]
  end

  def self.view_url(box_view_id)
    values = { "document_id" => box_view_id }.to_json

    headers = { "Content-Type" => 'application/json',
                "Authorization" => "Token #{TOKEN}" }

    response = JSON[RestClient.post(VIEW_URL, values, headers)]
    response['urls']['view']
  end
end
