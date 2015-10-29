class KamiWrapper
  TOKEN = ENV['KAMI_API_KEY']
  EMBED_URL = 'https://api.notablepdf.com/embed/documents'
  VIEW_URL = 'https://api.notablepdf.com/embed/sessions'

  attr_reader :submission

  def initialize(submission, user)
    @submission = submission
    @user = user
  end

  def upload
    values = {
      "document_url" => submission.url,
      "name" => submission.file.filename
    }.to_json

    headers = {
      :content_type => 'application/json',
      :authorization => "Token #{TOKEN}"
    }

    JSON[RestClient.post EMBED_URL, values, headers]
  end

  def status
    headers = { :authorization => "Token #{TOKEN}" }

    JSON[RestClient.get(EMBED_URL + "/#{submission.kami_id}"), headers]
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
