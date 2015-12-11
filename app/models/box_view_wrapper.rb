class BoxViewWrapper
  TOKEN = ENV['BOX_VIEW_API_KEY']
  UPLOAD_URL = 'https://view-api.box.com/1/documents'
  VIEW_URL = 'https://api.notablepdf.com/embed/sessions'

  def self.upload(file_url, file_name)
    values = {
      "url" => file_url,
      "name" => file_name
    }.to_json

    headers = {
      "Content-Type" => 'application/json',
      "Authorization" => "Token #{TOKEN}"
    }

    JSON[RestClient.post(UPLOAD_URL, values, headers)]
  end

  def status(box_view_id)
    headers = { :authorization => "Token #{TOKEN}" }

    JSON[RestClient.get(EMBED_URL + "/#{box_view_id}"), headers]
  end

  def view_url
    values = {
      "document_identifier" => submission.kami_id,
      "user" => {
        "name" => user.full_name,
        "user_id" => user.id
      },
      "expires_at" => 45.minutes.from_now,
      "viewer_options" => {
        "theme" => "light"
      }
    }.to_json

    headers = {
      :content_type => 'application/json',
      :authorization => "Token #{TOKEN}"
    }

    response = JSON[RestClient.post VIEW_URL, values, headers]
    response['viewer_url']
  end
end
