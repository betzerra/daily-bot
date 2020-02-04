require_relative 'telegram_step'

class RandomGifStep < TelegramStep
  def handle_step
    gif = gif_message(random_giphy_tag)
    send_gif(gif)
  end

  private

  def gif_message(tag)
    response = conn.get "https://api.giphy.com/v1/gifs/random\?api_key\=#{giphy_token}\&tag\=#{tag}"
    json = JSON.parse(response.body)
    json['data']['image_url']
  end

  def random_giphy_tag
    payload['tags'].sample
  end

  def giphy_token
    payload['token']
  end
end
