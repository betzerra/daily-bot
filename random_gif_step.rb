require 'faraday'

require './telegram_step'

class RandomGifStep < TelegramStep
  def initialize(token, chat_id, giphy_token, payload)
    @giphy_token = giphy_token
    @payload = payload
    @token = token
    @chat_id = chat_id
  end

  def gif_message(tag)
    response = Faraday.get "https://api.giphy.com/v1/gifs/random\?api_key\=#{@giphy_token}\&tag\=#{tag}"
    json = JSON.parse(response.body)
    json['data']['image_url']
  end

  def random_giphy_tag
    @payload['tags'].sample
  end

  def handle_step
    gif = gif_message(random_giphy_tag)
    send_gif(gif)
  end
end
