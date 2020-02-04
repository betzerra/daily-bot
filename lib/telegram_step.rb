require 'faraday'
require 'telegram/bot'

class TelegramStep
  attr_writer :conn

  def initialize(token, chat_id, payload)
    @token = token
    @chat_id = chat_id
    @payload = payload
  end

  def conn
    @conn ||= Faraday.new
  end

  private

  attr_reader :token, :chat_id, :payload

  def send_message(text)
    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_message(
        chat_id: chat_id,
        text: text,
        parse_mode: 'markdown'
      )
    end
  end

  def send_gif(url)
    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_animation(
        chat_id: chat_id,
        animation: url,
        disable_notification: true
      )
    end
  end
end
