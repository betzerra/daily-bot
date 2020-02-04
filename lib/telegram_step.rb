require 'telegram/bot'
require 'faraday'

class TelegramStep
  def initialize(token, chat_id, payload)
    @token = token
    @chat_id = chat_id
    @payload = payload
  end

  def send_message(text)
    Telegram::Bot::Client.run(@token) do |bot|
      bot.api.send_message(
        chat_id: @chat_id,
        text: text,
        parse_mode: 'markdown'
      )
    end
  end

  def send_gif(url)
    Telegram::Bot::Client.run(@token) do |bot|
      bot.api.send_animation(
        chat_id: @chat_id,
        animation: url,
        disable_notification: true
      )
    end
  end
end
